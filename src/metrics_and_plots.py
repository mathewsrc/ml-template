import json
import polars as pl
import matplotlib.pyplot as plt
from sklearn.metrics import ConfusionMatrixDisplay


def plot_confusion_matrix(model, X_test, y_test):
    _ = ConfusionMatrixDisplay.from_estimator(model, X_test, y_test, cmap=plt.cm.Blues)
    plt.savefig("plots/confusion_matrix.png")

def save_metrics(metrics):
    with open("metrics/metrics.json", "w") as fp:
        json.dump(metrics, fp)
        
def save_predictions(y_true, y_pred):
    # Save predictions as csv in metrics/
    predictions = pl.DataFrame({"y_true": y_true, "y_pred": y_pred})
    predictions.write_csv("metrics/predictions.csv")