"""
AuraScan - Face Emotion & Skin Analysis Engine
DeepFace + OpenCV + MediaPipe tabanlı analiz modülü
"""

import cv2
import numpy as np
import mediapipe as mp
from deepface import DeepFace
import logging

logger = logging.getLogger(__name__)

# ─────────────────────────────────────────────
# Öneri Veritabanı
# ─────────────────────────────────────────────

EMOTION_RECOMMENDATIONS = {
    "happy": [
        "Mutluluğun yüzünde parlıyor! Bu enerjiyi etrafınla paylaş.",
        "Yaratıcı projeler için harika bir an — şu an tam zamanı!",
        "Bu ruh halinde hedef belirlemek çok etkili olabilir.",
        "Sevdiklerinle kaliteli zaman geçir, anılar biriktir.",
    ],
    "sad": [
        "Üzülmek normaldir — duygularını bastırma, hisset.",
        "Hafif bir yürüyüş veya yoga, ruh halini hızla iyileştirebilir.",
        "Güvendiğin biriyle konuşmak büyük bir rahatlama sağlar.",
        "Sevdiğin bir müzik listesi aç, küçük bir keyif al.",
        "Günlük tutmak duyguları işlemene yardımcı olabilir.",
    ],
    "angry": [
        "4-7-8 nefes tekniğini dene: 4 say nefes al, 7 tut, 8'de ver.",
        "Fiziksel egzersiz öfkeyi serbest bırakmanın en sağlıklı yolu.",
        "Tepki vermeden önce kendine biraz alan ver.",
        "Sıcak bir duş veya meditasyon sinir sistemini sakinleştirir.",
        "Duygularını yazmak içinizdeki gerilimi azaltır.",
    ],
    "fear": [
        "5-4-3-2-1 tekniği: 5 şey gör, 4 şeye dokun, 3 şey duy.",
        "Derin nefes almak parasempatik sinir sistemini aktive eder.",
        "Korkular küçük adımlara bölündüğünde yönetilebilir hale gelir.",
        "Güvendiğin biriyle endişelerini paylaş.",
        "Şimdiki ana odaklan — geleceği kontrol edemezsin ama şu anı yaşayabilirsin.",
    ],
    "surprise": [
        "Sürprizlere açık olmak büyüme işareti — bu güzel!",
        "Yeni deneyimleri kucakla, en iyi anılar sürpriz anlarda doğar.",
        "Tepki vermeden önce bir an dur ve durumu değerlendir.",
        "Bu açık enerjiyle yeni bir şey öğrenmeyi dene bugün.",
    ],
    "disgust": [
        "Güçlü değerlerin var — bu sana rehberlik ediyor.",
        "Kontrol edemediğin şeyleri kabullenmek için farkındalık egzersizi yap.",
        "Bu duyguyu pozitif bir değişime dönüştür.",
        "Yaşam alanını düzenlemek ve temizlemek iyi hissettirir.",
    ],
    "neutral": [
        "Dengeli ve sakin bir zihin — derin çalışma için ideal an.",
        "Meditasyon veya nefes egzersizleriyle bu anı derinleştir.",
        "Önemli kararlar almak için harika bir ruh hali.",
        "Bu netliği yaratıcı bir projeye yönlendir.",
    ],
}

SKIN_TIPS = {
    "oily": [
        "Günde iki kez köpüklü, hafif bir temizleyici kullan.",
        "Yağ bazlı olmayan (non-comedogenic) nemlendirici tercih et.",
        "Niacinamid veya salisilik asit içeren ürünler gözenekleri küçültür.",
        "Yağlanmayı gün içinde kontrol etmek için kağıt mendil kullan.",
        "Nemlendiriciden vazgeçme — nemsizlik yağlanmayı artırır!",
    ],
    "dry": [
        "Kremsamsı, yoğun bir temizleyici kullan — köpüklü olanlardan kaçın.",
        "Hyalüronik asit veya ceramid içeren nemlendirici tercih et.",
        "Günde en az 2 litre su iç.",
        "Çok sıcak duş almaktan kaçın, cildi kurutur.",
        "Uyumadan önce yüzüne zengin bir gece kremi uygula.",
        "Yaşam alanında nemlendirici (humidifier) kullan.",
    ],
    "combination": [
        "T bölgesi (alın, burun, çene) ve yanaklar için farklı ürünler kullan.",
        "T bölgesine kil maskesi, yanaklara nemlendirici uygula.",
        "Hafif, dengeleyen bir tonik, cilt pH'ını ayarlar.",
        "'Kombinasyon cilt' etiketli ürünleri tercih et.",
        "Haftalık 1-2 kez exfoliant kullanmayı unutma.",
    ],
    "normal": [
        "Cilin dengeli — rutinini koru!",
        "Her sabah SPF 30+ güneş kremi uygula.",
        "C vitamini serumu cildi parlaklaştırır ve korur.",
        "Haftada 1-2 kez hafif peeling ile ölü cilt hücrelerini uzaklaştır.",
        "Bol su iç ve dengeli beslen.",
    ],
}

LIFESTYLE_TIPS = [
    "Her sabah SPF 30+ güneş koruyucu kullan — en iyi anti-aging önlemi.",
    "Gece 7-9 saat uyku, cilt hücrelerinin yenilenmesi için şart.",
    "Antioksidan açısından zengin besinler (yaban mersini, ıspanak) tüket.",
    "Düzenli egzersiz kan dolaşımını artırarak cilde doğal ışıltı verir.",
    "Uyumadan önce makyaj temizlemeden yatma.",
    "Günde en az 8 bardak su içmek cilt elastikiyetini korur.",
    "Stres yönetimi cildin genel sağlığını doğrudan etkiler.",
]

ANTI_AGE_TIPS = [
    "Retinol içeren bir gece serumu kullanmayı düşün.",
    "Peptid bazlı kremler cilt sıkılığını destekler.",
    "Gözaltı kremi kullanmak ince çizgileri geciktirir.",
    "Kolesterol ve şeker tüketimini azaltmak cildi genç tutar.",
]

# ─────────────────────────────────────────────
# Cilt Analiz Fonksiyonları
# ─────────────────────────────────────────────

def _classify_skin_type(texture_var: float, bright_var: float) -> str:
    if bright_var > 900:
        return "oily"
    elif texture_var < 12:
        return "dry"
    elif bright_var > 450:
        return "combination"
    return "normal"


def _classify_skin_tone(brightness: float) -> str:
    if brightness > 185:
        return "fair"
    elif brightness > 150:
        return "light"
    elif brightness > 115:
        return "medium"
    elif brightness > 75:
        return "tan"
    return "deep"


def _texture_label(laplacian_var: float) -> str:
    if laplacian_var < 80:
        return "very smooth"
    elif laplacian_var < 200:
        return "smooth"
    elif laplacian_var < 450:
        return "normal"
    elif laplacian_var < 800:
        return "slightly textured"
    return "textured"


def _redness_label(redness: float) -> str:
    if redness > 25:
        return "high"
    elif redness > 12:
        return "medium"
    return "low"


def analyze_skin(face_img: np.ndarray) -> dict | None:
    """Yüz ROI üzerinde kapsamlı cilt analizi yapar."""
    if face_img is None or face_img.size == 0:
        return None

    face_img = cv2.resize(face_img, (256, 256))

    # Renk uzayları
    lab = cv2.cvtColor(face_img, cv2.COLOR_BGR2LAB)
    ycrcb = cv2.cvtColor(face_img, cv2.COLOR_BGR2YCrCb)

    # Cilt maskesi (YCrCb — daha tutarlı)
    lower = np.array([0, 133, 77], dtype=np.uint8)
    upper = np.array([255, 173, 127], dtype=np.uint8)
    mask = cv2.inRange(ycrcb, lower, upper)

    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

    if np.sum(mask > 0) < 200:
        return None

    # 1. Parlaklık (LAB L kanalı)
    l_ch = lab[:, :, 0]
    skin_l = l_ch[mask > 0].astype(float)
    avg_brightness = float(np.mean(skin_l))
    bright_var = float(np.var(skin_l))

    # 2. Doku / pürüzsüzlük — Laplacian varyansı
    gray = cv2.cvtColor(face_img, cv2.COLOR_BGR2GRAY)
    lap = cv2.Laplacian(gray, cv2.CV_64F)
    texture_var = float(np.var(lap))

    # 3. Kızarıklık (R - G farkı)
    b, g, r = cv2.split(face_img.astype(float))
    skin_r = r[mask > 0]
    skin_g = g[mask > 0]
    redness = float(np.mean(skin_r - skin_g))

    # 4. Düzenlilik (renk homojenliği)
    uniformity = float(np.std(skin_l))
    uniformity_score = int(max(0, min(100, 100 - uniformity)))

    # 5. Nemlendirme tahmini (doku + kızarıklık penaltısı)
    hydration_score = int(max(0, min(100, 100 - texture_var / 12 - max(0, redness) * 1.5)))

    skin_type = _classify_skin_type(texture_var, bright_var)
    skin_tone = _classify_skin_tone(avg_brightness)
    texture_quality = _texture_label(texture_var)
    redness_level = _redness_label(redness)

    return {
        "type": skin_type,
        "tone": skin_tone,
        "texture_quality": texture_quality,
        "redness_level": redness_level,
        "brightness": round(avg_brightness, 1),
        "redness_score": round(redness, 1),
        "texture_score": round(texture_var, 1),
        "hydration_score": hydration_score,
        "uniformity_score": uniformity_score,
    }


# ─────────────────────────────────────────────
# Öneri Motoru
# ─────────────────────────────────────────────

def _build_recommendations(emotion_data: dict | None, skin_data: dict | None, age: int) -> dict:
    emotion_tips = []
    skin_tips_list = []
    lifestyle = list(LIFESTYLE_TIPS)

    if emotion_data:
        dominant = emotion_data.get("dominant", "neutral")
        emotion_tips = EMOTION_RECOMMENDATIONS.get(dominant, EMOTION_RECOMMENDATIONS["neutral"])

    if skin_data:
        skin_type = skin_data.get("type", "normal")
        skin_tips_list = list(SKIN_TIPS.get(skin_type, SKIN_TIPS["normal"]))

        # Ekstra cilt ipuçları
        if skin_data.get("redness_level") == "high":
            skin_tips_list.append("Aloe vera veya yeşil çay özlü ürünler kızarıklığı azaltır.")
            skin_tips_list.append("Sert peeling ve çok sıcak su yüzünü daha da tahriş edebilir.")
        if skin_data.get("hydration_score", 50) < 40:
            skin_tips_list.append("Cildin dehidrate görünüyor — hyalüronik asit serum kullanmayı dene.")
        if skin_data.get("uniformity_score", 50) < 45:
            skin_tips_list.append("C vitamini serumu cilt tonu eşitsizliğini zamanla azaltır.")
            skin_tips_list.append("Düzenli SPF kullanımı lekelerin koyulaşmasını önler.")

    if age and age > 30:
        lifestyle.extend(ANTI_AGE_TIPS[:2])
    if age and age > 40:
        lifestyle.extend(ANTI_AGE_TIPS[2:])

    return {
        "emotion_tips": emotion_tips,
        "skin_tips": skin_tips_list,
        "lifestyle_tips": lifestyle[:6],  # en fazla 6 yaşam tarzı ipucu
    }


# ─────────────────────────────────────────────
# Ana Analiz Fonksiyonu
# ─────────────────────────────────────────────

def analyze_face(image_bytes: bytes) -> dict:
    """
    Ham görüntü byte'larını alır, tam analiz sonucu döner.
    """
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("Görüntü çözümlenemedi")

    result: dict = {
        "emotion": None,
        "demographics": None,
        "skin": None,
        "recommendations": {},
    }

    age = 0

    try:
        analysis = DeepFace.analyze(
            img,
            actions=["emotion", "age", "gender"],
            enforce_detection=False,
            silent=True,
        )

        if isinstance(analysis, list):
            analysis = analysis[0]

        # ── Duygu ──
        emotions: dict = analysis.get("emotion", {})
        dominant_emotion: str = analysis.get("dominant_emotion", "neutral")
        result["emotion"] = {
            "dominant": dominant_emotion,
            "scores": {k: round(float(v), 2) for k, v in emotions.items()},
        }

        # ── Demografik ──
        age = int(analysis.get("age", 0))
        gender_raw = analysis.get("dominant_gender") or analysis.get("gender", "Unknown")
        if isinstance(gender_raw, dict):
            gender_raw = max(gender_raw, key=gender_raw.get)
        result["demographics"] = {"age": age, "gender": str(gender_raw)}

        # ── Yüz ROI → Cilt Analizi ──
        region = analysis.get("region", {})
        if region and all(k in region for k in ("x", "y", "w", "h")):
            x, y, w, h = (int(region[k]) for k in ("x", "y", "w", "h"))
            pad = 15
            x1 = max(0, x - pad)
            y1 = max(0, y - pad)
            x2 = min(img.shape[1], x + w + pad)
            y2 = min(img.shape[0], y + h + pad)
            face_roi = img[y1:y2, x1:x2]
        else:
            face_roi = img

        result["skin"] = analyze_skin(face_roi)

    except Exception as exc:
        logger.warning("DeepFace analiz hatası: %s", exc)

    result["recommendations"] = _build_recommendations(result["emotion"], result["skin"], age)
    return result
