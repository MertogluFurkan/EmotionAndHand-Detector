"""
AuraScan - FastAPI Backend
Yüz duygusu ve cilt analizi REST API
"""

import logging
import uvicorn
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from analyzer import analyze_face

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

app = FastAPI(
    title="AuraScan API",
    description="AI tabanlı yüz duygusu ve cilt analizi",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["system"])
async def health_check():
    return {"status": "ok", "service": "AuraScan API v1.0"}


@app.post("/analyze", tags=["analysis"])
async def analyze(image: UploadFile = File(...)):
    """
    Yüklenen görüntüyü analiz eder.

    - **image**: JPEG / PNG formatında yüz görüntüsü (multipart/form-data)

    Döner:
    - emotion: baskın duygu + tüm skorlar
    - demographics: tahmini yaş ve cinsiyet
    - skin: cilt tipi, ton, nemlendirme, doku vb.
    - recommendations: kişiselleştirilmiş öneriler
    """
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Dosya bir görüntü olmalıdır (JPEG/PNG).")

    image_bytes = await image.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Boş dosya gönderildi.")

    logger.info("Analiz başlıyor — %s, %.1f KB", image.filename, len(image_bytes) / 1024)

    try:
        data = analyze_face(image_bytes)
        logger.info("Analiz tamamlandı — dominant emotion: %s", data.get("emotion", {}).get("dominant", "?") if data.get("emotion") else "?")
        return {"success": True, "data": data}

    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    except Exception as exc:
        logger.error("Beklenmeyen hata: %s", exc, exc_info=True)
        raise HTTPException(status_code=500, detail=f"Analiz başarısız: {exc}") from exc


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True, log_level="info")
