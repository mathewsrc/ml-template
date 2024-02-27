import json
import polars as pl
from sklearn.model_selection import train_test_split
from metrics_and_plots import plot_confusion_matrix, save_metrics, save_predictions, save_roc_auc
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
import mlflow
import pickle
from pathlib import Path
from dvc.api import params_show
from utils import PROCESSED_DATASET, TARGET_COLUMN, load_data, load_hyperparameters

params = params_show()
rf_max_depth = params["train"]["max_depth"]
rf_n_estimators = params["train"]["n_estimators"]
random_state = params["random_state"]


def train_model(
	X_train,
	y_train,
	hyperparameters={
		"max_depth": rf_max_depth,
		"n_estimators": rf_n_estimators,
		"random_state": random_state,
	},
):
	model = RandomForestClassifier(**hyperparameters)

	model.fit(X_train, y_train)

	# Save model in models/
	model_path = Path("models/model.pkl")
	with open(model_path, "wb") as file:
		pickle.dump(model, file)

	return model


def evaluate_model(model, X_test, y_test, float_precision=4):
	y_pred = model.predict(X_test)
	accuracy = accuracy_score(y_test, y_pred)
	precision = precision_score(y_test, y_pred)
	recall = recall_score(y_test, y_pred)
	f1 = f1_score(y_test, y_pred)
	y_proba = model.predict_proba(X_test)[:, 1]
	roc_auc = roc_auc_score(y_test, y_proba)
	metrics = {
		"accuracy": accuracy,
		"precision": precision,
		"recall": recall,
		"f1_score": f1,
		"roc_auc": roc_auc,
	}

	save_predictions(y_test, y_pred)

	return json.loads(json.dumps(metrics), parse_float=lambda x: round(float(x), float_precision))


def main():
	X, y = load_data(PROCESSED_DATASET)
	X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=1993)

	hyperparameters = load_hyperparameters("hyperparameters.json")
	model = train_model(X_train, y_train, hyperparameters=hyperparameters)
	metrics = evaluate_model(model, X_test, y_test)

	print("====================Test Set Metrics==================")
	print(json.dumps(metrics, indent=2))
	print("======================================================")

	save_metrics(metrics)
	plot_confusion_matrix(model, X_test, y_test)
	save_roc_auc(model, X_test, y_test)


if __name__ == "__main__":
	main()
