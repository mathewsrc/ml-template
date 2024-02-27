#!/bin/bash

# Create DVC plots 

for plot in plots/*.png; do
    echo "Displaying plot: $plot"
    poetry run dvc plots show $plot
done

for metric in metrics/*.csv; do
    echo "Displaying metric: $metrics"
    poetry run dvc plots show $metric
done