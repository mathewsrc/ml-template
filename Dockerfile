FROM public.ecr.aws/lambda/python:3.12

# Install dependencies
RUN pip3 install \ 
     --no-cache-dir \
     --platform manylinux2014_x86_64 \
     --target "${LAMBDA_TASK_ROOT}" \
     --implementation cp \
     --python-version 3.12 \ 
     --only-binary=:all: --upgrade python-dotenv==1.0.1 \
          scikit-learn==1.4.1.post1 \
          polars==0.20.9 \
          fastapi==0.109.2 \
          pydantic==2.6.1 \
          uvicorn==0.27.1 \
          boto3==1.34.44 \
          mangum==0.17.0

# Copy function code
COPY ./api/main.py  ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler
CMD [ "main.handler" ]
