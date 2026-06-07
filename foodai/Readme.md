# Food AI

## Parameters
- --continue-from YYYY_mm_dd-HH-MM-SS <br>
Use to continue from checkpoint. Set to timestamp of checkpoint folder to continue from latest epoch. Default is none.

- --image-size XxY <br>
Size of images for training in pixels. Default is 300x300

- --workers N <br>
Number of training workers. Default is 8

- --batch-size N <br>
Size of training batches. Default is 16

- --epoch-number N <br>
Number of training epochs. Default is 10

- --model-name <string> <br>
Name of model to fine-tune. Default is efficientnet_b3

## Prepare environment
You'll need python 3.12+, python virtualenv, git, pip
```
git clone https://github.com/grilj-lucija/moceradi-project.git
cd ./moceradi-project/foodai
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
Download [data](https://www.kaggle.com/datasets/moltean/fruits). And extract archive inside `./datasources/kaggle_fruit_360`

## Run fine tune
- Run with default settings
```
python ./fine_tune.py
```

- Continue from latest epoch checkpoint in `./checkpoints/2026_06_07-22-54-33`
```
python ./fine_tune.py --continue-from 2026_06_07-22-54-33
```