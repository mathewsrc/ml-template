import json
import polars as pl
from sklearn.model_selection import train_test_split
from metrics_and_plots import save_best_param, save_hp_tuning_results
from utils import PROCESSED_DATASET, TARGET_COLUMN
from sklearn.ensemble import RandomForestClassifier
from dvc.api import params_show
from sklearn.model_selection import GridSearchCV

params = params_show()
rf_max_depth = params["train"]["max_depth"]
rf_n_estimators = params["train"]["n_estimators"]
random_state = params["random_state"]
cv = params["cv"]

def train_model(X_train, y_train):
    model = RandomForestClassifier(random_state=random_state)
    param_grid = json.load(open("config/hp_config.json", "r"))
    grid_search = GridSearchCV(model, param_grid, cv=cv, n_jobs=-1)
    grid_search.fit(X_train, y_train)
    return grid_search

def load_data(file_path):
    data = pl.read_csv(file_path).to_pandas()
    X = data.drop(TARGET_COLUMN, axis=1)
    y = data[TARGET_COLUMN]
    return X, y

def main():
    X, y = load_data(PROCESSED_DATASET)
    X_train, _, y_train, _ = train_test_split(X, y, random_state=random_state)
    
    grid_search = train_model(X_train, y_train)
    #model = grid_search.best_estimator_
    best_param = grid_search.best_params_
    save_best_param(best_param)
    save_hp_tuning_results(grid_search.cv_results_)

if __name__ == "__main__":
    main()

