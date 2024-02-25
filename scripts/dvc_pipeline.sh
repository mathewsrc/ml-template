#!/bin/bash

# Create a new DVC pipeline to preprocess and train a model

poetry run dvc stage add --force\
    -n preprocess \
    -d src/preprocess.py -d src/utils.py -d raw_dataset/apple_quality.csv  \
    -o processed_dataset/apple_quality.csv \
    python src/preprocess.py

poetry run dvc stage add --force\
    -n train \
    -d src/train.py -d src/metrics_and_plots.py -d src/utils.py -d processed_dataset/apple_quality.csv \
    -o models/model.pkl -o reports/confusion_matrix.png -o metrics/metrics.json \
    python src/train.py

poetry run dvc dag

poetry run dvc repro

cat dvc.lock 