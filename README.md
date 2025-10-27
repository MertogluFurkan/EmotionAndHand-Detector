# Emotion & Hand Gesture Detector 🤖✋🙂

Bu proje, Python ve OpenCV kullanılarak hem **yüz ifadesi (duygu) analizi** hem de **el hareketi tanıma** işlevlerini gerçekleştiren gerçek zamanlı bir bilgisayarlı görü uygulamasıdır.

---

## 📌 Özellikler

- 🎭 **Yüz Duygu Tanıma** (DeepFace ile)
  - angry, happy, sad, neutral vb.
  - Sol üst köşede güncel duygu durumu gösterilir.

- ✋ **El Hareketi Algılama** (MediaPipe ile)
  - 👍 Başparmak yukarı → `El işareti: 👍`
  - 👎 Başparmak aşağı → `El işareti: 👎`
  - 👆 Sadece işaret parmağı açık → `1`
  - ✌️ İşaret + orta parmak açık → `2`
  - ✋ Bütün parmaklar açık → `OPEN_HAND`
  - 🤙 Shaka (baş ve serçe açık) → `SHAKA`

---

## 🛠️ Kullanılan Kütüphaneler

- [OpenCV](https://pypi.org/project/opencv-python/)
- [MediaPipe](https://pypi.org/project/mediapipe/)
- [DeepFace](https://pypi.org/project/deepface/)
- [TensorFlow](https://www.tensorflow.org/)
- [NumPy](https://numpy.org/)

---

## 🚀 Kurulum

1. Bu repoyu klonla:
   ```bash
   git clone https://github.com/MertogluFurkan/EmotionAndHand-Detector.git
   cd EmotionAndHand-Detector

   python3 -m venv venv
source venv/bin/activate  # (Windows: venv\Scripts\activate)

pip install -r requirements.txt



Kullanım:
python3 main.py
