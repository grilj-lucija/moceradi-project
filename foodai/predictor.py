import torch
import torch.nn as nn
import timm
from PIL import Image
from torchvision import transforms


DEVICE = "cuda" if torch.cuda.is_available() else "cpu"


def load_model(model_path):
    data = torch.load(model_path, map_location=DEVICE)

    model = timm.create_model("efficientnet_b3", pretrained=False)
    model.classifier = nn.Linear(
        model.classifier.in_features,
        len(data["idx_to_class"])
    )

    model.load_state_dict(data["model_state_dict"])
    model.to(DEVICE)
    model.eval()

    return model, data["idx_to_class"], data["image_size"]


def get_transform(image_size):
    return transforms.Compose([
        transforms.Resize(image_size),
        transforms.ToTensor(),
        transforms.Normalize(
            [0.485, 0.456, 0.406],
            [0.229, 0.224, 0.225]
        )
    ])

def predict(image_path, model, transform, idx_to_class):
    try:
        image = Image.open(image_path)
    except:
        print("Couldn't open image")
        exit(1)
    image = image.convert("RGB")
    image = transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        logits = model(image)
        probs = torch.softmax(logits, dim=1)

    conf, idx = torch.max(probs, dim=1)

    idx = idx.item()
    conf = conf.item()

    if isinstance(idx_to_class, dict):
        label = idx_to_class.get(str(idx), idx_to_class.get(idx))
    else:
        label = idx_to_class[idx]

    return label, conf


if __name__ == "__main__":
    MODEL_PATH = "./models/food_classifier_b3_2026_06_04-22-03-34.pth"
    #IMAGE_PATH = "test.jpg"
    IMAGE_PATH = "test4.jpg"
    #IMAGE_PATH = "test2.png"

    model, idx_to_class, image_size = load_model(MODEL_PATH)
    transform = get_transform(image_size)

    label, confidence = predict(
        IMAGE_PATH,
        model,
        transform,
        idx_to_class
    )

    print("Prediction:", label)
    print("Confidence:", confidence)