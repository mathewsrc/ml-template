import shutil
from pathlib import Path
import json
import polars as pl

DATASET_TYPES = ["test", "train"]
DROP_COLNAMES = ["A_id"]
TARGET_COLUMN = "Quality"
RAW_DATASET = "raw_dataset/apple_quality.csv"
PROCESSED_DATASET = "processed_dataset/apple_quality.csv"


def delete_and_recreate_dir(path):
	try:
		shutil.rmtree(path)
	except:
		pass
	finally:
		Path(path).mkdir(parents=True, exist_ok=True)


def load_data(file_path):
	data = pl.read_csv(file_path).to_pandas()
	X = data.drop(TARGET_COLUMN, axis=1)
	y = data[TARGET_COLUMN]
	return X, y


def load_hyperparameters(hyperparameter_file):
	with open(hyperparameter_file, "r") as json_file:
		hyperparameters = json.load(json_file)
	return hyperparameters
