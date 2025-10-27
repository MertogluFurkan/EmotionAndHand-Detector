import time
import cv2
from deepface import DeepFace
import mediapipe as mp

# Mediapipe el tespiti ayarları
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=False,
                       max_num_hands=2,
                       min_detection_confidence=0.7)
mp_draw = mp.solutions.drawing_utils

# Kamera başlat
cap = cv2.VideoCapture(0)

# Gesture yazdırma için basit cooldown (her el indexi için)
last_gesture_time = {}  # {hand_index: (gesture_name, timestamp)}
COOLDOWN = 1.0  # saniye

while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)

    emotion_label = ""

    # ----- Yüz ve Duygu Analizi -----
    try:
        results = DeepFace.analyze(frame, actions=['emotion'], enforce_detection=False)

        if isinstance(results, dict):
            results = [results]

        for res in results:
            x = res['region']['x']
            y = res['region']['y']
            w = res['region']['w']
            h = res['region']['h']
            emotion = res['dominant_emotion']
            emotion_label = emotion

            # Yüzde kare çizme kaldırıldı; yüz üstü etiketi göster
            cv2.putText(frame, emotion, (x, max(y - 10, 20)),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
    except Exception as e:
        # Hata olsa da devam et
        # print(f"Yüz analizi hatası: {e}")
        pass

    # Sol üst köşeye duygu yazısı
    if emotion_label:
        cv2.putText(frame, f"Duygu: {emotion_label}", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)

    # ----- El Tespiti -----
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    result = hands.process(rgb)

    if result.multi_hand_landmarks:
        # multi_hand_landmarks ve multi_handedness sıraları birbirine karşılık gelir
        for i, hand_landmarks in enumerate(result.multi_hand_landmarks):
            # eldeki landmarkları çiz
            mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

            # handedness (Left / Right) al (varsa)
            handedness_label = None
            if result.multi_handedness and len(result.multi_handedness) > i:
                try:
                    handedness_label = result.multi_handedness[i].classification[0].label
                except Exception:
                    handedness_label = None

            # parmak uçları id'leri: [thumb_tip, index_tip, middle_tip, ring_tip, pinky_tip]
            tips_ids = [4, 8, 12, 16, 20]
            fingers = []

            # Başparmak tespiti (el yönüne göre)
            thumb_tip = hand_landmarks.landmark[tips_ids[0]]
            thumb_ip = hand_landmarks.landmark[3]  # IP joint (bir önceki nokta)
            # Eğer handedness bilinmiyorsa varsayımsal sağ el davranışı kullan
            if handedness_label == "Right":
                thumb_open = thumb_tip.x > thumb_ip.x
            elif handedness_label == "Left":
                thumb_open = thumb_tip.x < thumb_ip.x
            else:
                # fallback: önceki basit kontrol (orijinal kodun mantığı)
                thumb_open = thumb_tip.x < thumb_ip.x

            fingers.append(1 if thumb_open else 0)

            # Diğer parmaklar: tip.y < pip.y ise parmak açık (y küçük => daha yukarı)
            for id in range(1, 5):
                tip = hand_landmarks.landmark[tips_ids[id]]
                pip = hand_landmarks.landmark[tips_ids[id] - 2]
                fingers.append(1 if tip.y < pip.y else 0)

            # Wrist ve tip koordinatları (noktasal kontroller için)
            wrist = hand_landmarks.landmark[0]
            # thumb tip y ile wrist karşılaştırması (yükseklik) -> yukarı/aşağı tespiti
            # Note: görüntü koordinatlarında y arttıkça aşağı iner.
            thumb_pointing_up = thumb_open and (thumb_tip.y < wrist.y - 0.05)    # yukarıda
            thumb_pointing_down = thumb_open and (thumb_tip.y > wrist.y + 0.05)  # aşağıda

            # Hangi gesture olduğunu belirle
            gesture = None

            # 👍 : başparmak açık + diğer parmaklar kapalı + başparmak yukarı
            if fingers == [1, 0, 0, 0, 0] and thumb_pointing_up:
                gesture = "THUMBS_UP"
            # 👎 : başparmak açık + diğer parmaklar kapalı + başparmak aşağı
            elif fingers == [1, 0, 0, 0, 0] and thumb_pointing_down:
                gesture = "THUMBS_DOWN"
            # 👆 (tek parmak: index yukarı; diğerleri kapalı) -> 1
            elif fingers[1] == 1 and fingers[2] == 0 and fingers[3] == 0 and fingers[4] == 0:
                gesture = "ONE"  # index up
            # ✌️ (index ve middle up; ring ve pinky kapalı) -> 2
            elif fingers[1] == 1 and fingers[2] == 1 and fingers[3] == 0 and fingers[4] == 0:
                gesture = "TWO"

            # Cooldown kontrolü ve print
            now = time.time()
            prev = last_gesture_time.get(i, (None, 0))
            prev_gesture, prev_time = prev

            if gesture is not None:
                # sadece değiştiyse veya cooldown geçtiyse yaz
                if gesture != prev_gesture or (now - prev_time) > COOLDOWN:
                    if gesture == "THUMBS_UP":
                        print("El işareti: 👍")
                    elif gesture == "THUMBS_DOWN":
                        print("El işareti: 👎")
                    elif gesture == "ONE":
                        print("1")
                    elif gesture == "TWO":
                        print("2")

                    last_gesture_time[i] = (gesture, now)
            else:
                # eğer artık hiçbir gesture yoksa zaman aşımı kaydını sıfırla (opsiyonel)
                last_gesture_time[i] = (None, now)

            # El etrafına dikdörtgen çiz (isteğe bağlı)
            h_img, w_img, _ = frame.shape
            x_list = [int(landmark.x * w_img) for landmark in hand_landmarks.landmark]
            y_list = [int(landmark.y * h_img) for landmark in hand_landmarks.landmark]
            x_min, x_max = min(x_list), max(x_list)
            y_min, y_max = min(y_list), max(y_list)
            cv2.rectangle(frame, (x_min, y_min), (x_max, y_max), (255, 0, 0), 2)

    # Görüntüyü göster
    cv2.imshow('Yüz ve El Takibi', frame)

    # 'q' tuşuna basıldığında çık
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()