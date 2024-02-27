import json
import polars as pl
import matplotlib.pyplot as plt
from sklearn.metrics import ConfusionMatrixDisplay, roc_curve

def plot_confusion_matrix(model, X_test, y_test):
    _ = ConfusionMatrixDisplay.from_estimator(model, X_test, y_test, cmap=plt.cm.Blues)
    plt.savefig("plots/confusion_matrix.png")

def save_metrics(metrics):
    with open("metrics/metrics.json", "w") as fp:
        json.dump(metrics, fp)
        
def save_predictions(y_true, y_pred):
    # Save predictions as csv in metrics/
    predictions = pl.DataFrame({"true_label": y_true, "predicted_label": y_pred})
    predictions.write_csv("metrics/predictions.csv")
    
def save_roc_auc(model, X_test, y_test):
    y_proba = model.predict_proba(X_test)[:, 1]
    fpr, tpr, _ = roc_curve(y_test, y_proba)
    pl.DataFrame({"fpr": fpr, "tpr": tpr}).write_csv("metrics/roc_curve.csv")