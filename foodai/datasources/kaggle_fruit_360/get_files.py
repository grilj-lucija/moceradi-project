from pathlib import Path
import classes as food_classes

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}

FOOD_TRAIN_DIRS = {
    "Almond": [
        "Almonds 1",
    ],
    "Apple": [
        "Apple 10",
        "Apple 11",
        "Apple 12",
        "Apple 13",
        "Apple 14",
        "Apple 17",
        "Apple 18",
        "Apple 19",
        "Apple 20",
        "Apple 21",
        "Apple 22",
        "Apple 23",
        "Apple 5",
        "Apple 6",
        "Apple 7",
        "Apple 8",
        "Apple 9",
        "Apple Braeburn 1",
        "Apple Red Yellow 2",
        "apple_crimson_snow_1",
        "apple_golden_1",
        "apple_golden_2",
        "apple_golden_3",
        "apple_granny_smith_1",
        "apple_pink_lady_1",
        "apple_red_1",
        "apple_red_2",
        "apple_red_3",
        "apple_red_delicios_1",
        "apple_red_yellow_1",
    ],
    "Avocado": [
        "Avocado Black 1",
        "Avocado Black 2",
        "Avocado Green 1",
    ],
    "Banana": [
        "Banana 3",
        "Banana 4",
    ],
    "Bean": [
        "Beans 1",
    ],
    "Blackberry": [
        "Blackberry 1",
        "Blackberry 2",
        "Blackberry 3",
        "Blackberry 4",
        "Blackberry 5",
    ],
    "Cabbage": [
        "Cabbage red 1",
        "cabbage_white_1",
    ],
    "Cashew": [
        "Caju seed 1",
    ],
    "Cantaloupe": [
        "Cantaloupe 3",
    ],
    "Carrot": [
        "Carrot 1",
    ],
    "Celery": [
        "Celery 1",
    ],
    "Cherry": [
        "Cherry 3",
        "Cherry 4",
        "Cherry 5",
        "Cherry Rainier 2",
        "Cherry Rainier 3",
        "Cherry Sour 1",
        "Cherry Wax 1",
        "Cherry Wax 2",
        "Cherry Wax Red 2",
        "Cherry Wax Red 3",
    ],
    "Cucumber": [
        "Cucumber 1",
        "Cucumber 3",
        "Cucumber 4",
        "Cucumber 5",
        "Cucumber 6",
        "Cucumber 7",
        "Cucumber 8",
        "Cucumber 9",
        "Cucumber 10",
        "Cucumber 11",
    ],
    "Date": [
        "Dates 2",
    ],
    "Eggplant": [
        "eggplant_long_1",
    ],
    "Ginger": [
        "Ginger 2",
    ],
    "Grape": [
        "Grape not ripen 1",
        "Grape pink 2",
    ],
    "Nectarine": [
        "Nectarine Flat 2",
    ],
    "Walnut": [
        "Nut 2",
        "Nut 3",
        "Nut 4",
        "Nut 5",
    ],
    "Onion": [
        "Onion Red 2",
        "Onion White 2",
        "Onion 2",
    ],
    "Orange": [
        "Orange peeled 1",
        "Orange 2",
        "Orange 3",
        "Orange 4",
    ],
    "Peach": [
        "Peach 3",
        "Peach 4",
        "Peach 5",
        "Peach 6",
    ],
    "Pear": [
        "Pear common 1",
        "Pear 1",
        "Pear 3",
        "Pear 5",
        "Pear 6",
        "Pear 7",
        "Pear 8",
        "Pear 9",
        "Pear 10",
        "Pear 11",
        "Pear 12",
        "Pear 13",
    ],
    "Pepper": [
        "Pepper 1",
        "Pepper 2",
        "Pepper Orange 2",
        "Pepper Red 2",
        "Pepper Red 3",
        "Pepper Red 4",
        "Pepper Red 5",
    ],
    "Pistachio": [
        "Pistachio 1",
    ],
    "Plum": [
        "Plum 4",
        "Plum 5",
    ],
    "Quince": [
        "Quince 2",
        "Quince 3",
        "Quince 4",
    ],
    "Raspberry": [
        "Raspberry 2",
        "Raspberry 3",
        "Raspberry 4",
        "Raspberry 5",
        "Raspberry 6",
    ],
    "Strawberry": [
        "Strawberry 2",
        "Strawberry 3",
    ],
    "Tomato": [ # & cherry tomato
        "Tomato 1",
        "Tomato 5",
        "Tomato 7",
        "Tomato 8",
        "Tomato 9",
        "Tomato 10",
        "Tomato Cherry Maroon 1",
        "Tomato Maroon 2",
        "Tomato Cherry Orange 1",
        "Tomato Cherry Yellow 1",
        "Tomato Cherry Red 2",
    ],
    "Zucchini": [
        "Zucchini dark 1",
        "Zucchini Green 1",
        "zucchini_1",
    ],
}

# Returns images in a list of (path, label)
def get_training_files(base_dir_str = "./fruits-360_original-size/fruits-360-original-size/Training"):
    base_dir = Path(base_dir_str)
    training_images = {}

    # Map paths to food name
    for food, dir_names in FOOD_TRAIN_DIRS.items():
        images = []
        for dir_name in dir_names:
            folder = (base_dir / dir_name).resolve()

            if not folder.exists():
                print(f"Folder {dir_name} does not exist")
                continue

            images.extend(file for file in folder.iterdir() if file.is_file() and file.suffix in IMAGE_EXTENSIONS)
        training_images[food] = images

    samples = []
    for label, paths in training_images.items():
        for p in paths:
            samples.append((p, food_classes.CLASS_TO_IDX[label]))

    return samples

if __name__ == "__main__":
    samples = get_training_files()
    print(samples)