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
    -o models/model.pkl \
    -m metrics/metrics.json \
    --plots-no-cache plots/confusion_matrix.png --plots-no-cache metrics/predictions.csv \
    --plots-no-cache metrics/roc_curve.csv \
    -p random_state -p train.max_depth -p train.n_estimators \
    python src/train.py

poetry run dvc dag

poetry run dvc repro
