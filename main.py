"""
AuraScan — Giriş noktası
Backend'i başlatmak için bu dosyayı çalıştır ya da start_backend.sh kullan.
"""
import subprocess
import sys
from pathlib import Path


def main():
    backend = Path(__file__).parent / "backend" / "main.py"
    print("🚀 AuraScan backend başlatılıyor → http://0.0.0.0:8000")
    subprocess.run([sys.executable, str(backend)], check=True)


if __name__ == "__main__":
    main()
