#!/bin/bash

# Define the input file and output files
TRAIN_FILE="train.csv"
TEST_FILE="test.csv"

# Define the S3 bucket
S3_BUCKET=$PROJECT_NAME

# Upload the files to S3
aws s3 cp $TRAIN_FILE s3://$S3_BUCKET/
aws s3 cp $TEST_FILE s3://$S3_BUCKET/