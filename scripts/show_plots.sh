#!/bin/bash

# Create DVC plots 

for plot in plots/*.png; do
    echo "Displaying plot: $plot"
    poetry run dvc plots show $plot
    poetry run dvc plots diff --target $plot main
done

for metric in metrics/*.csv; do
    echo "Displaying metric: $metrics"
    poetry run dvc plots show $metric
    poetry run dvc plots diff --target $metric main
done
