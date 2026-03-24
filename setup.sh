#!/usr/bin/env bash
# ─────────────────────────────────────────────
# AuraScan — Tam kurulum scripti
# Kullanım: ./setup.sh
# ─────────────────────────────────────────────
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
FLUTTER_DIR="$ROOT/flutter_app"
BACKEND_DIR="$ROOT/backend"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() { echo -e "\n${BLUE}▶ $1${NC}"; }
print_ok()   { echo -e "${GREEN}✓ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠  $1${NC}"; }
print_err()  { echo -e "${RED}✗ $1${NC}"; }

# ── 1. Ön koşul kontrolleri ──────────────────
print_step "Ön koşullar kontrol ediliyor..."

command -v python3 >/dev/null 2>&1 || { print_err "python3 bulunamadı. Lütfen Python 3.9+ kur."; exit 1; }
command -v flutter >/dev/null 2>&1 || { print_err "flutter bulunamadı. flutter.dev/docs/get-started adresini ziyaret et."; exit 1; }

PYTHON_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
print_ok "Python $PYTHON_VER bulundu"

FLUTTER_VER=$(flutter --version 2>&1 | head -1)
print_ok "$FLUTTER_VER bulundu"

# ── 2. Python backend kurulumu ───────────────
print_step "Python backend kuruluyor..."

cd "$BACKEND_DIR"
if [ ! -d "venv" ]; then
  python3 -m venv venv
  print_ok "Sanal ortam oluşturuldu"
fi

source venv/bin/activate
pip install -q --upgrade pip
pip install -q -r requirements.txt
print_ok "Python bağımlılıkları yüklendi"
deactivate

# ── 3. Flutter uygulaması kurulumu ──────────
print_step "Flutter uygulaması kuruluyor..."

# Flutter proje iskeleti oluştur (yoksa)
if [ ! -f "$FLUTTER_DIR/android/app/src/main/AndroidManifest.xml" ]; then
  print_warn "Flutter proje iskeleti oluşturuluyor (flutter create)..."

  TEMP_DIR=$(mktemp -d)
  flutter create --org com.aurascan --project-name aurascan "$TEMP_DIR/aurascan" --quiet

  # Android ve iOS yapılandırmalarını kopyala
  cp -r "$TEMP_DIR/aurascan/android" "$FLUTTER_DIR/"
  cp -r "$TEMP_DIR/aurascan/ios" "$FLUTTER_DIR/"
  cp -r "$TEMP_DIR/aurascan/test" "$FLUTTER_DIR/"
  cp "$TEMP_DIR/aurascan/.gitignore" "$FLUTTER_DIR/" 2>/dev/null || true

  rm -rf "$TEMP_DIR"
  print_ok "Flutter iskelet oluşturuldu"
fi

# Android izinleri ekle
MANIFEST="$FLUTTER_DIR/android/app/src/main/AndroidManifest.xml"
if ! grep -q "android.permission.CAMERA" "$MANIFEST" 2>/dev/null; then
  # <manifest> tagından sonra izinleri ekle
  sed -i.bak '/<manifest/a\
    <uses-permission android:name="android.permission.CAMERA" />\
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />\
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />\
    <uses-feature android:name="android.hardware.camera" />\
    <uses-feature android:name="android.hardware.camera.autofocus" />' "$MANIFEST"
  rm -f "${MANIFEST}.bak"
  print_ok "Android kamera izinleri eklendi"
fi

# iOS Info.plist açıklamaları ekle
IOS_PLIST="$FLUTTER_DIR/ios/Runner/Info.plist"
if [ -f "$IOS_PLIST" ] && ! grep -q "NSCameraUsageDescription" "$IOS_PLIST"; then
  sed -i.bak '/<dict>/a\
\t<key>NSCameraUsageDescription<\/key>\
\t<string>AuraScan yüz analizi için kamera kullanır<\/string>\
\t<key>NSPhotoLibraryUsageDescription<\/key>\
\t<string>AuraScan analiz için fotoğraf galerisine erişir<\/string>' "$IOS_PLIST"
  rm -f "${IOS_PLIST}.bak"
  print_ok "iOS kamera izinleri eklendi"
fi

# Flutter bağımlılıkları
cd "$FLUTTER_DIR"
flutter pub get
print_ok "Flutter bağımlılıkları yüklendi"

# ── 4. Özet ─────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  AuraScan kurulum tamamlandı!             ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo "Kullanım:"
echo ""
echo -e "  ${YELLOW}1. Backend'i başlat:${NC}"
echo "     ./start_backend.sh"
echo ""
echo -e "  ${YELLOW}2. Flutter'ı çalıştır (yeni terminalde):${NC}"
echo "     cd flutter_app && flutter run"
echo ""
echo -e "  ${YELLOW}Not:${NC} Android emülatörde IP adresi 10.0.2.2'dir."
echo "  iOS simülatörde localhost kullanılır."
echo "  Fiziksel cihazda: lib/services/api_service.dart"
echo "  dosyasındaki _baseUrl'i bilgisayarının IP'si ile güncelle."
echo ""
