import json
import polars as pl
from sklearn.model_selection import train_test_split
from metrics_and_plots import plot_confusion_matrix, save_metrics
from utils import PROCESSED_DATASET, TARGET_COLUMN
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
import mlflow

RFC_FOREST_DEPTH = 2

def train_model(X_train, y_train):
    model = RandomForestClassifier(
        max_depth=RFC_FOREST_DEPTH, n_estimators=5, random_state=1993
    )
    model.fit(X_train, y_train)
    return model


def evaluate_model(model, X_test, y_test, float_precision=4):
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred)
    recall = recall_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred)
    metrics = {
        "accuracy": accuracy,
        "precision": precision,
        "recall": recall,
        "f1_score": f1,
    }

    return json.loads(
        json.dumps(metrics), parse_float=lambda x: round(float(x), float_precision)
    )

def load_data(file_path):
    data = pd.read_csv(file_path)
    X = data.drop(TARGET_COLUMN, axis=1)
    y = data[TARGET_COLUMN]
    return X, y


def main():
    X, y = load_data(PROCESSED_DATASET)
    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=1993)

    model = train_model(X_train, y_train)
    metrics = evaluate_model(model, X_test, y_test)

    print("====================Test Set Metrics==================")
    print(json.dumps(metrics, indent=2))
    print("======================================================")

    save_metrics(metrics)
    plot_confusion_matrix(model, X_test, y_test)


if __name__ == "__main__":
    main()

