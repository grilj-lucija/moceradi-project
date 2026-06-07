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

# Default values
IM_SIZE = (300, 300)
NUM_WORKERS = 8
BATCH_SIZE = 16
EPOCH_NUMBER = 10
MODEL_NAME = "efficientnet_b3"


DEVICE = "cuda" if torch.cuda.is_available() else "cpu"


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


def save_checkpoint(epoch, loss, start_date, model, optimizer):
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


def load_checkpoint(path, model, optimizer):
    checkpoint = torch.load(path, map_location=DEVICE)

    model.load_state_dict(checkpoint["model_state_dict"])
    optimizer.load_state_dict(checkpoint["optimizer_state_dict"])

    return checkpoint["epoch"] + 1


def load_checkpoint_if_exists(timestamp, model, optimizer):
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

    return load_checkpoint(latest_file, model, optimizer)


def train_one_epoch(loader, model, optimizer, criterion):
    model.train()
    total_loss = 0

    for x, y in loader:
        x = x.to(DEVICE, non_blocking=True)
        y = y.to(DEVICE, non_blocking=True)

        optimizer.zero_grad()
        out = model(x)

        loss = criterion(out, y)
        loss.backward()
        optimizer.step()

        total_loss += loss.item()

    return total_loss / len(loader)


def run_training(samples, timestamp, model, optimizer, criterion, args):
    train_tfms = transforms.Compose([
        transforms.Resize(args["im_size"]),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406],
                             [0.229, 0.224, 0.225])
    ])

    dataset = FoodDataset(samples, transform=train_tfms)
    loader = DataLoader(dataset, batch_size=args["batch_size"], shuffle=True, num_workers=args["workers"], pin_memory=True, persistent_workers=False)
    start_epoch = load_checkpoint_if_exists(timestamp, model, optimizer)

    for epoch in range(start_epoch, args["epoch_number"]):
        loss = train_one_epoch(loader, model, optimizer, criterion)
        print(f"Epoch {epoch}: {loss:.4f}")
        save_checkpoint(epoch, loss, timestamp, model, optimizer)


def save_report(train_time, train_samples, timestamp, args):
    training_report = {
        "train_time": train_time,
        "im_size": args["im_size"],
        "workers": args["workers"],
        "batch_size": args["batch_size"],
        "sample_size": len(train_samples),
        "epoch_number": args["epoch_number"],
    }

    reports_dir = Path("./reports")
    reports_dir.mkdir(exist_ok=True)

    report_path = reports_dir / f"report_{timestamp}.json"

    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(training_report, f, indent=2, ensure_ascii=False)

    print(f"Report saved to {report_path}")

def save_model(timestamp, model, args):
    models_dir = Path("./models")
    models_dir.mkdir(exist_ok=True)

    model_path = models_dir / f"food_classifier_b3_{timestamp}.pth"

    torch.save({
        "model_state_dict": model.state_dict(),
        "idx_to_class": food_classes.IDX_TO_CLASS,
        "class_to_idx": food_classes.CLASS_TO_IDX,
        "image_size": args["im_size"],
    }, model_path)

    print(f"Model saved to {model_path}")

def print_help():
    print(
"""
Help:
--continue-from YYYY_mm_dd-HH-MM-SS<,N>
    Use to continue from checkpoint. N is optional epoch number

--image-size XxY
    Size of images for training in pixels

--workers N
    Number of training workers

--batch-size N
    Size of training batches

--epoch-number N
    Number of training epochs

--model-name <string>
    Name of model to fine-tune
""")

def is_nan(num):
    return num != num

def str_to_imsize(im_size_str):
    im_size_px = im_size_str.split("x")
    x = int(im_size_px[0])
    y = int(im_size_px[1])
    if is_nan(x) or is_nan(y):
        return None
    return x, y

def get_arg_idx(argv, arg_name):
    try:
        return argv.index(arg_name)
    except ValueError:
        return None

def get_args():
    argc = len(sys.argv)
    if len(sys.argv) <= 1:
        return {}
    argv = sys.argv
    args = {}

    if get_arg_idx(argv, "--help") is not None:
        print_help()
        exit(0)

    arg_idx = get_arg_idx(argv, "--continue-from")
    if arg_idx is not None and argc >= arg_idx + 1:
        args["continue_from"] = argv[arg_idx + 1]

    arg_idx = get_arg_idx(argv, "--image-size")
    if arg_idx is not None and argc >= arg_idx + 1:
        im_size = str_to_imsize(argv[arg_idx + 1])
        if im_size is not None:
            args["im_size"] = im_size

    arg_idx = get_arg_idx(argv, "--workers")
    if arg_idx is not None and argc >= arg_idx + 1:
        workers = int(argv[arg_idx + 1])
        if not is_nan(workers):
            args["workers"] = workers

    arg_idx = get_arg_idx(argv, "--batch-size")
    if arg_idx is not None and argc >= arg_idx + 1:
        batch_size = int(argv[arg_idx + 1])
        if not is_nan(batch_size):
            args["batch_size"] = batch_size

    arg_idx = get_arg_idx(argv, "--epoch-number")
    if arg_idx is not None and argc >= arg_idx + 1:
        epoch_number = int(argv[arg_idx + 1])
        if not is_nan(epoch_number):
            args["epoch_number"] = epoch_number

    arg_idx = get_arg_idx(argv, "--model-name")
    if arg_idx is not None and argc >= arg_idx + 1:
        args["model_name"] = argv[arg_idx + 1]

    return args

def get_training_samples():
    return kag_fruit_360.get_training_files("./datasources/kaggle_fruit_360/fruits-360_original-size/fruits-360-original-size/Training")

def main():
    print("Start")

    args = get_args()

    if "continue_from" in args:
        print("Continuing from ", args["continue_from"])
        training_timestamp = args["continue_from"]
    else:
        training_timestamp = datetime.now().strftime("%Y_%m_%d-%H-%M-%S")

    if "im_size" not in args:
        args["im_size"] = IM_SIZE

    if "workers" not in args:
        args["workers"] = NUM_WORKERS

    if "batch_size" not in args:
        args["batch_size"] = BATCH_SIZE

    if "epoch_number" not in args:
        args["epoch_number"] = EPOCH_NUMBER

    if "model_name" not in args:
        args["model_name"] = MODEL_NAME

    train_samples = get_training_samples()

    #TODO remove after testing !!!!
    train_samples = train_samples[:100]

    print("Start training")
    model = timm.create_model(args["model_name"], pretrained=True)
    model.classifier = nn.Linear(model.classifier.in_features, len(food_classes.CLASS_NAMES))

    model.to(DEVICE)

    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)

    train_start_time = time.time()
    run_training(train_samples, training_timestamp, model, optimizer, criterion, args)
    train_time = time.time() - train_start_time
    print("Training time: ", train_time)
    save_report(train_time, train_samples, training_timestamp, args)
    save_model(training_timestamp, model, args)

    print("Start testing")


if __name__ == '__main__':
    main()
