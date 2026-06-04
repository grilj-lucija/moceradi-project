import json
import os.path
from datetime import datetime
import time
from pathlib import Path
import sys
import re

from torch.utils.data import Dataset, DataLoader
from PIL import Image
import classes as food_classes
from torchvision import transforms
import timm
import torch
import torch.nn as nn
import datasources.kaggle_fruit_360.get_files as kag_fruit_360
from sklearn.model_selection import train_test_split

IM_SIZE = (300, 300)
NUM_WORKERS = 8
BATCH_SIZE = 16
EPOCH_NUMBER = 10

class FoodDataset(Dataset):
    def __init__(self, samples, transform=None):
        self.samples = samples
        self.transform = transform

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, label = self.samples[idx]

        image = Image.open(img_path).convert("RGB")

        if self.transform:
            image = self.transform(image)

        return image, label


train_tfms = transforms.Compose([
    transforms.Resize(IM_SIZE),
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(10),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

val_tfms = transforms.Compose([
    transforms.Resize(IM_SIZE),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

model = timm.create_model('efficientnet_b3', pretrained=True)
model.classifier = nn.Linear(model.classifier.in_features, len(food_classes.CLASS_NAMES))

device = "cuda" if torch.cuda.is_available() else "cpu"
model.to(device)

criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)


def save_checkpoint(epoch, loss, start_date):
    checkpoints_dir = Path(f"./checkpoints")
    checkpoints_dir.mkdir(exist_ok=True)

    checkpoints_dir = Path(f"./checkpoints/{start_date}")
    checkpoints_dir.mkdir(exist_ok=True)

    checkpoint_path = checkpoints_dir / f"epoch_{epoch}.pth"

    torch.save({
        "epoch": epoch,
        "model_state_dict": model.state_dict(),
        "optimizer_state_dict": optimizer.state_dict(),
        "loss": loss,
        "idx_to_class": food_classes.IDX_TO_CLASS,
        "class_to_idx": food_classes.CLASS_TO_IDX,
    }, checkpoint_path)

    print(f"Checkpoint saved: {checkpoint_path}")


def load_checkpoint(path):
    checkpoint = torch.load(path, map_location=device)

    model.load_state_dict(checkpoint["model_state_dict"])
    optimizer.load_state_dict(checkpoint["optimizer_state_dict"])

    return checkpoint["epoch"] + 1


def load_checkpoint_if_exists(timestamp):
    checkpoints_dir = Path(f"./checkpoints/{timestamp}")
    if not os.path.isdir(checkpoints_dir):
        return 0

    checkpoint_files = list(checkpoints_dir.glob("epoch_*.pth"))
    if not checkpoint_files:
        return 0

    def extract_epoch(path):
        match = re.search(r"epoch_(\d+)\.pth", path.name)
        return int(match.group(1)) if match else -1

    latest_file = max(checkpoint_files, key=extract_epoch)
    if not latest_file:
        return 0

    return load_checkpoint(latest_file)


def train_one_epoch(loader):
    model.train()
    total_loss = 0

    for x, y in loader:
        x = x.to(device, non_blocking=True)
        y = y.to(device, non_blocking=True)

        optimizer.zero_grad()
        out = model(x)

        loss = criterion(out, y)
        loss.backward()
        optimizer.step()

        total_loss += loss.item()

    return total_loss / len(loader)


def run_training(samples, timestamp):
    dataset = FoodDataset(samples, transform=train_tfms)
    loader = DataLoader(dataset, batch_size=BATCH_SIZE, shuffle=True, num_workers=NUM_WORKERS, pin_memory=True, persistent_workers=False)
    start_epoch = load_checkpoint_if_exists(timestamp)

    for epoch in range(start_epoch, EPOCH_NUMBER):
        loss = train_one_epoch(loader)
        print(f"Epoch {epoch}: {loss:.4f}")
        save_checkpoint(epoch, loss, timestamp)


def predict(image):
    image = val_tfms(image).unsqueeze(0).to(device)

    with torch.no_grad():
        logits = model(image)
        probs = nn.functional.softmax(logits, dim=1)

    idx = probs.argmax().item()
    return food_classes.IDX_TO_CLASS[idx], probs.max().item()

def save_report(train_time, train_samples, timestamp):
    training_report = {
        "train_time": train_time,
        "im_size": IM_SIZE,
        "workers": NUM_WORKERS,
        "batch_size": BATCH_SIZE,
        "sample_size": len(train_samples),
        "epoch_number": EPOCH_NUMBER,
    }

    reports_dir = Path("./reports")
    reports_dir.mkdir(exist_ok=True)

    report_path = reports_dir / f"report_{timestamp}.json"

    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(training_report, f, indent=2, ensure_ascii=False)

    print(f"Report saved to {report_path}")

def save_model(timestamp):
    models_dir = Path("./models")
    models_dir.mkdir(exist_ok=True)

    model_path = models_dir / f"food_classifier_b3_{timestamp}.pth"

    torch.save({
        "model_state_dict": model.state_dict(),
        "idx_to_class": food_classes.IDX_TO_CLASS,
        "class_to_idx": food_classes.CLASS_TO_IDX,
        "image_size": IM_SIZE,
    }, model_path)

    print(f"Model saved to {model_path}")

def get_arg_idx(argv, arg_name):
    try:
        return argv.index(arg_name)
    except ValueError:
        return 0


# returns True + args obj if args present and False otherwise
def get_args():
    argc = len(sys.argv)
    if len(sys.argv) <= 1:
        return False, {}
    argv = sys.argv
    help = get_arg_idx(argv, "--help")
    if help > 0:
        print(
"""
Help:
To continue use --continue-from YYYY_mm_dd-HH-MM-SS
Or just start training a new model with default parameters
""")
        exit(0)
    contine_from = get_arg_idx(argv, "--continue-from")
    if contine_from == -1:
        return False, {}
    if argc < contine_from + 1:
        print("--continue-from found but nothing specified")
        return False, {}
    return True, {"continue_from": argv[contine_from + 1]}

def main():
    print("Start")
    have_args, args = get_args()
    if have_args:
        print("Continuing from ", args["continue_from"])
        training_timestamp = args["continue_from"]
    else:
        training_timestamp = datetime.now().strftime("%Y_%m_%d-%H-%M-%S")

    #TODO make separate get_testing_files()
    #train_samples = kag_fruit_360.get_training_files()
    samples = kag_fruit_360.get_training_files("./datasources/kaggle_fruit_360/fruits-360_original-size/fruits-360-original-size/Training")

    train_samples, val_samples = train_test_split(
        samples,
        test_size=0.2,
        random_state=42,
        shuffle=True
    )

    #TODO remove after testing !!!!
    #train_samples = train_samples[:100]

    print("Start training")
    train_start_time = time.time()
    run_training(train_samples, training_timestamp)
    train_time = time.time() - train_start_time
    print("Training time: ", train_time)
    save_report(train_time, train_samples, training_timestamp)
    save_model(training_timestamp)

    print("Start testing")


if __name__ == '__main__':
    main()
