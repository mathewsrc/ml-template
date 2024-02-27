# Serveless Machine Learning Operations Template with AWS Lambda Functions 

## Requirements

- AWS account
- Terraform Cloud account
- GitHub account
- Docker
- AWS CLI
- Terraform CLI
- Poetry

## How to use this template

First, follow this tutorial from Hashicorp to use Terraform with GitHub Actions:

https://developer.hashicorp.com/terraform/tutorials/automation/github-actions

Then, create an AWS account if you do not have one:

https://aws.amazon.com/resources/create-account/

After you finish the AWS account setup, you must add secrets for `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in GitHub Actions secrets as you 
did for Terraform.

If you do not have Docker you can find instructions in this link:

https://docs.docker.com/get-docker/

Now it's time to install AWS CLI, Terraform CLI, and Poetry. I already created scripts to help you with that :)

Using the terminal

```bash
chmod +x secrets/install_awscli.sh
./secrets/install_awscli.sh

chmod +x secrets/install_poetry.sh
./secrets/install_poetry.sh

chmod +x secrets/install_terraform.sh
./secrets/install_terraform.sh
```

Using Makefile command

```bash
make install-tools
```

Now you need to configure AWS CLI. Use the following command in the terminal and provide the required information. Do not
forget to set an AWS region as this project will retrieve it using AWS CLI to provision Lambda and S3:

```bash
aws configure
```

You must create an environment variable with your project name (replace the <ANY_NAME_YOU_LIKE>):

```bash
export PROJECT_NAME="<ANY_NAME_YOU_LIKE>"
```

Replace the `AWS_REGION` in the `.github/workflows/cd.yml` file with the region you set in AWS CLI:

```
env:
  AWS_REGION: us-east-1   # replace 
```

In order to be able to use GitHub Actions you will need to allow GitHub Actions to create pull requests.
You can change the permission in: Repository Settings -> Actions -> General -> Workflows permissions ->
`Allow GitHub Actions to create and aprove pull requests`  




