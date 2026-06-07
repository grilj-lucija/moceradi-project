CLASS_CALORIE_VALUES = {
    "Almond": {
        "cal_100g": 575
    },
    "Apple": {
        "cal_100g": 52
    },
    "Apricot": {
        "cal_100g": 48
    },
    "Avocado": {
        "cal_100g": 160
    },
    "Banana": {
        "cal_100g": 105
    },
    "Bean": {
        "cal_100g": 88
    },
    "Beetroot": {
        "cal_100g": 43
    },
    "Blackberry": {
        "cal_100g": 62
    },
    "Blueberry": {
        "cal_100g": 83
    },
    "Cabbage": {
        "cal_100g": 28
    },
    "Cashew": {
        "cal_100g": 553
    },
    "Cantaloupe": {
        "cal_100g": 61
    },
    "Carrot": {
        "cal_100g": 25
    },
    "Cauliflower": {
        "cal_100g": 25
    },
    "Celery": {
        "cal_100g": 14
    },
    "Cherry": {
        "cal_100g": 74
    },
    "Chestnut": {
        "cal_100g": 200
    },
    "Clementine": { # & Mandarine
        "cal_100g": 47
    },
    "Coconut": {
        "cal_100g": 280
    },
    "Corn": {
        "cal_100g": 90
    },
    "Cucumber": {
        "cal_100g": 15
    },
    "Date": {
        "cal_100g": 281
    },
    "Eggplant": {
        "cal_100g": 24
    },
    "Fig": {
        "cal_100g": 75
    },
    "Ginger": {
        "cal_100g": 79
    },
    "Grape": {
        "cal_100g": 66
    },
    "Grapefruit": {
        "cal_100g": 42
    },
    "Hazelnut": {
        "cal_100g": 628
    },
    "Kaki": { # Persimmon
        "cal_100g": 70
    },
    "Kiwi": {
        "cal_100g": 61
    },
    "Kohlrabi": {
        "cal_100g": 27
    },
    "Lemon": {
        "cal_100g": 29
    },
    "Lime": {
        "cal_100g": 30
    },
    "Mango": {
        "cal_100g": 65
    },
    "Nectarine": {
        "cal_100g": 44
    },
    "Walnut": {
        "cal_100g": 654
    },
    "Onion": {
        "cal_100g": 42
    },
    "Orange": {
        "cal_100g": 62
    },
    "PassionFruit": {
        "cal_100g": 97
    },
    "Peach": {
        "cal_100g": 39
    },
    "Pear": {
        "cal_100g": 58
    },
    "Pepper": {
        "cal_100g": 24
    },
    "Pineapple": {
        "cal_100g": 48
    },
    "Pistachio": {
        "cal_100g": 557
    },
    "Plum": {
        "cal_100g": 46
    },
    "Pomegranate": {
        "cal_100g": 68
    },
    "Pomelo": {
        "cal_100g": 38
    },
    "Potato": {
        "cal_100g": 104
    },
    "Sweet_potato": {
        "cal_100g": 86
    },
    "Quince": {
        "cal_100g": 57
    },
    "Raspberry": {
        "cal_100g": 52
    },
    "Redcurrant": {
        "cal_100g": 56
    },
    "Strawberry": {
        "cal_100g": 32
    },
    "Tomato": { # & cherry tomato
        "cal_100g": 18
    },
    "Watermelon": {
        "cal_100g": 30
    },
    "Zucchini": {
        "cal_100g": 16
    },
    "Pasta": {
        "cal_100g": 220
    },
}

CLASS_NAMES = CLASS_CALORIE_VALUES.keys()

CLASS_TO_IDX = {c: i for i, c in enumerate(CLASS_NAMES)}
IDX_TO_CLASS = {i: c for c, i in CLASS_TO_IDX.items()}