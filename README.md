# AuraScan 🌟

**AI destekli yüz duygusu & cilt analizi uygulaması**

Flutter (UI) + Python/FastAPI (Analiz Motoru) mimarisi

---

## Özellikler

| Özellik | Açıklama |
|---|---|
| 😊 Duygu Analizi | 7 temel duygu tespiti (mutlu, üzgün, kızgın, korkmuş, şaşkın, iğrenmiş, nötr) |
| 🧴 Cilt Analizi | Cilt tipi (yağlı/kuru/karma/normal), ton, doku, nemlendirme, kızarıklık |
| 📊 Görsel Metrikler | Dairesel gauge'lar + radar grafik + ilerleme çubukları |
| 💡 Kişisel Öneriler | Duygu, cilt ve yaşam tarzı bazlı ipuçları |
| 📷 Kamera | Ön kamera, oval yüz kılavuzu, galeri desteği |
| ✨ Animasyonlar | Splash ekranı, geçişler, canlı UI animasyonları |

---

## Mimari

```
aurascan/
├── backend/                   # Python FastAPI backend
│   ├── main.py               # API sunucusu (port 8000)
│   ├── analyzer.py           # DeepFace + OpenCV analiz motoru
│   └── requirements.txt
│
├── flutter_app/               # Flutter mobil uygulama
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── theme/app_theme.dart
│       ├── models/analysis_result.dart
│       ├── services/api_service.dart
│       ├── screens/
│       │   ├── splash_screen.dart   # Açılış ekranı
│       │   ├── home_screen.dart     # Ana sayfa
│       │   ├── camera_screen.dart   # Kamera & çekim
│       │   └── result_screen.dart   # Analiz sonuçları
│       └── widgets/
│           ├── metric_card.dart
│           └── recommendation_card.dart
│
├── main.py                    # Backend başlatıcı (kısayol)
├── start_backend.sh           # Backend başlatma scripti
└── setup.sh                   # Tam kurulum scripti
```

---

## Kurulum

### Otomatik (önerilen)

```bash
./setup.sh
```

### Manuel

#### 1. Backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
# → http://localhost:8000 adresinde çalışır
# → Swagger UI: http://localhost:8000/docs
```

#### 2. Flutter Uygulaması

```bash
cd flutter_app
flutter create . --project-name aurascan   # İskelet oluştur (ilk seferinde)
flutter pub get
flutter run
```

**Android izinleri** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-feature android:name="android.hardware.camera" />
```

**iOS izinleri** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>AuraScan yüz analizi için kamera kullanır</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Analiz için fotoğraf galerisine erişir</string>
```

---

## API Endpoint'leri

| Method | Path | Açıklama |
|---|---|---|
| GET | `/health` | Sunucu durumu |
| POST | `/analyze` | Görüntü analizi (multipart/form-data) |

### Örnek Yanıt (`/analyze`)

```json
{
  "success": true,
  "data": {
    "emotion": {
      "dominant": "happy",
      "scores": { "happy": 87.3, "neutral": 8.1, "sad": 2.4, ... }
    },
    "demographics": { "age": 27, "gender": "Woman" },
    "skin": {
      "type": "normal",
      "tone": "medium",
      "texture_quality": "smooth",
      "redness_level": "low",
      "hydration_score": 72,
      "uniformity_score": 68,
      "brightness": 143.5
    },
    "recommendations": {
      "emotion_tips": ["..."],
      "skin_tips": ["..."],
      "lifestyle_tips": ["..."]
    }
  }
}
```

---

## IP Adresi Ayarı

`flutter_app/lib/services/api_service.dart` içinde `_baseUrl`'i ortamına göre güncelle:

| Ortam | URL |
|---|---|
| iOS Simulator | `http://localhost:8000` |
| Android Emulator | `http://10.0.2.2:8000` |
| Fiziksel cihaz | `http://<bilgisayar-IP>:8000` |

---

## Teknolojiler

**Backend:** Python · FastAPI · DeepFace · OpenCV · MediaPipe · NumPy

**Frontend:** Flutter · Dart · fl_chart · flutter_animate · google_fonts · camera · http

---

## Ekran Görüntüleri (Akış)

```
Splash Screen → Home Screen → Camera Screen → Result Screen
     ↓               ↓              ↓               ↓
  Animasyonlu     Hızlı ipuçları  Oval kılavuz   Duygu + Cilt
  açılış          + Özellikler    + Çekim butonu + Radar grafik
                                                 + Öneriler
```
