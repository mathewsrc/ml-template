install-tools:
	@echo "Installing tools"
	@echo "Installing tools"
	chmod +x scripts/install_poetry.sh
	chmod +x scripts/install_awscli.sh
	chmod +x scripts/install_terraform.sh
	@echo "Checking if Poetry is installed..."
	@if ! command -v poetry &> /dev/null; then scripts/install_poetry.sh; fi
	@echo "Checking if AWS CLI is installed..."
	@if ! command -v aws &> /dev/null; then scripts/install_awscli.sh; fi
	@echo "Checking if Terraform is installed..."
	@if ! command -v terraform &> /dev/null; then scripts/install_terraform.sh; fi

setup:
	@echo "Setting up virtual environment"
	poetry shell

install:
	@echo "Installing dependencies"
	poetry install 

format:
	@echo "Formating code"
	chmod +x ./format.sh
	./format.sh

lint:
	@echo "Liting code"
	chmod +x ./lint.sh
	./lint.sh

test:
	@echo "Running tests"
	poetry run python -m pytest -vv tests/*.py --cov=tests

run-app:
	@echo "Running local app with uvicorn"
	poetry run uvicorn src.app.main:app --host 127.0.0.1 --port 8000

predict:
	@echo "Predicting with local app"
	curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"predict":"10"}'

trigger-actions:
	@echo "Triggering GitHub Actions"
	git commit --amend --no-edit && git push --force-with-lease

lambda-predict:
	@echo "Testing Lambda function"
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"payload":"10"}'

docker-build:
	@echo "Building Docker container"
	docker build -t app .

docker-run:
	@echo "Starting Docker container"
	docker run -d -p 8000:8000 app

mlflow-ui:
	@echo "Starting MLflow UI"
	mlflow ui

dvc-init:
	@echo "Initializing DVC"
	poetry run dvc init

dvc-add:
	@echo "Adding data to DVC"
	poetry run dvc add raw_dataset/dataset.csv

dvc-add-remote:
	@echo "Adding remote storage to DVC. For cloud storage use: s3://mlflow-dvc-demo"
	poetry run dvc remote add -d storage /tmp/dvc/localremote 

dvc-push:
	@echo "Pushing data to DVC remote storage"
	poetry run dvc push

dvc-pull:
	@echo "Pulling data from DVC remote storage"
	poetry run dvc pull

dvc-metrics:
	@echo "Showing DVC metrics"
	poetry run dvc metrics show

dvc-plots:
	@echo "Showing DVC plots"
	poetry run dvc plots show predictions.csv

aws-user:
	@echo "Check current AWS user signed in to AWS CLI"
	aws sts get-caller-identity

aws-region:
	@echo "Check current AWS region"
	aws configure get region

lambda-info:
	@echo "Info Lambda functions"
	aws lambda list-functions --max-items 10

tf-init:
	@echo "Initializing Terraform <Initialize the provider with plugin>"
	chmod +x ./scripts/terraform_init.sh
	./scripts/terraform_init.sh

tf-plan:
	@echo "Planning Terraform <Preview of resources to be created>"
	cd terraform/ && terraform plan -input=false 

tf-outp:
	@echo "Output Terraform <Output of resources to be created>"
	cd terraform && terraform output

tf-destroy:
	@echo "Destroying Terraform <Destroy infrastruture resources>"
	cd terraform && terraform destroy -auto-approve

tf-fmt:
	@echo "Formating Terraform <Auto-format Terraform code>"
	cd terraform && terraform fmt -recursive

tf-val:
	@echo "Validating Terraform <Validate Terraform code>"
	cd terraform && terraform validate

tf-deploy:
	@echo "Deploying Terraform <Deploy infrastruture resources>"
	cd terraform && terraform fmt -recursive && terraform validate && terraform apply -auto-approve -input=false

tf-upload:
	@echo "Uploading Terraform <Upload infrastruture resources>"
	cd terraform && terraform init 
	chmod +x ./scripts/upload_state.sh
	chmod +x ./scripts/terraform_migrate.sh
	./scripts/upload_state.sh 
	./scripts/terraform_migrate.sh

tf-mgt:
	@echo "Migrating Terraform <Migrate infrastructure resources>"
	chmod +x ./scripts/terraform_migrate.sh
	./scripts/terraform_migrate.sh

tf-refresh:
	@echo "Refreshing Terraform <Refresh infrastruture resources>"
	cd terraform && terraform refresh

tf-st-list:
	@echo "List Terraform state <List infrastruture resources>"
	cd terraform && terraform state list

json-fmt:
	@echo "Formating JSON <Auto-format JSON code>"
	jq . .data/example.json > temp.json && mv temp.json .data/example.json

all: install format lint
