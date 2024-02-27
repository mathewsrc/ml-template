import json
import polars as pl
import matplotlib.pyplot as plt
from sklearn.metrics import ConfusionMatrixDisplay, roc_curve

def plot_confusion_matrix(model, X_test, y_test):
    _ = ConfusionMatrixDisplay.from_estimator(model, X_test, y_test, cmap=plt.cm.Blues)
    path = "plots/confusion_matrix.png"
    plt.savefig(path)

def save_metrics(metrics):
    path = "metrics/metrics.json" 
    with open(path, "w") as fp:
        json.dump(metrics, fp)
        
def save_predictions(y_true, y_pred):
    # Save predictions as csv in metrics/
    predictions = pl.DataFrame({"true_label": y_true, "predicted_label": y_pred})
    path = "metrics/predictions.csv"
    predictions.write_csv(path)
    
def save_roc_auc(model, X_test, y_test):
    y_proba = model.predict_proba(X_test)[:, 1]
    fpr, tpr, _ = roc_curve(y_test, y_proba)
    path = "metrics/roc_curve.csv"
    pl.DataFrame({"fpr": fpr, "tpr": tpr}).write_csv(path)
    
def save_best_param(best_param):
    with open("config/best_param.json", "w") as file:
        json.dump(best_param, file)
        
def save_hp_tunning_results(results):
    markdown_table = pl.DataFrame(results).to_pandas().to_markdown(index=False)
    with open("hp_tunning_results.md", "w") as markdown:
        markdown.write(markdown_table)