import io
import os

import torch
from fastapi import FastAPI, File, HTTPException, UploadFile
from PIL import Image, UnidentifiedImageError

from classes import CLASS_CALORIE_VALUES
from predictor import DEVICE, get_transform, load_model

MODEL_PATH = os.getenv(
    "MODEL_PATH",
    "models/food_classifier_b3_2026_06_04-22-03-34.pth",
)

app = FastAPI(title="FoodAI inference service")

_model = None
_idx_to_class = None
_transform = None


@app.on_event("startup")
def _load() -> None:
    global _model, _idx_to_class, _transform
    _model, _idx_to_class, image_size = load_model(MODEL_PATH)
    _transform = get_transform(image_size)


def _resolve_label(idx: int):
    if isinstance(_idx_to_class, dict):
        return _idx_to_class.get(str(idx), _idx_to_class.get(idx))
    return _idx_to_class[idx]


def _calories(label):
    entry = CLASS_CALORIE_VALUES.get(label)
    if entry is None:
        return None
    return entry.get("cal_100g")


def _center_square_crop(image: Image.Image) -> Image.Image:
    width, height = image.size
    side = min(width, height)
    left = (width - side) // 2
    top = (height - side) // 2
    return image.crop((left, top, left + side, top + side))


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/recognize")
async def recognize(file: UploadFile = File(...)):
    if _model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    raw = await file.read()
    try:
        image = Image.open(io.BytesIO(raw)).convert("RGB")
    except UnidentifiedImageError:
        raise HTTPException(status_code=400, detail="Invalid image file")

    image = _center_square_crop(image)
    tensor = _transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        probs = torch.softmax(_model(tensor), dim=1)

    conf, idx = torch.max(probs, dim=1)
    label = _resolve_label(idx.item())

    return {
        "label": label,
        "confidence": conf.item(),
        "cal_100g": _calories(label),
    }
