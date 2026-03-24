#!/usr/bin/env bash
# ─────────────────────────────────────────────
# AuraScan — Python backend başlatıcı
# Kullanım: ./start_backend.sh
# ─────────────────────────────────────────────
set -e

cd "$(dirname "$0")/backend"

# Sanal ortam oluştur (yoksa)
if [ ! -d "venv" ]; then
  echo "⚙️  Sanal ortam oluşturuluyor..."
  python3 -m venv venv
fi

# Aktive et
# shellcheck disable=SC1091
source venv/bin/activate

echo "📦 Bağımlılıklar yükleniyor..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo ""
echo "🚀 AuraScan API başlatılıyor → http://0.0.0.0:8000"
echo "   Swagger UI: http://localhost:8000/docs"
echo "   (Durdurmak için Ctrl+C)"
echo ""

python main.py
