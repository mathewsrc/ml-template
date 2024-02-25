import shutil
from pathlib import Path

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
