#!/bin/bash

# Create a new DVC pipeline to preprocess and train a model

poetry run dvc stage add \
    -n preprocess \ 
    -d preprocess.py -d utils.py -d raw_dataset/raw_data.csv \ 
    -o processed_dataset/processed_data.csv \ 
    python src/preprocess.py

poetry run dvc stage add \
    -n train \
    -d train.py -d metrics_and_plots.py -d utils.py -d processed_dataset/processed_data.csv \
    -o model.pkl -o confusion_matrix.png -o metrics.json \
    python src/train.py

poetry run dvc dag

poetry run dvc repro

cat dvc.lock 