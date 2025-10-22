#!/bin/bash
set -e

BUILD_DIR="build"
LAMBDA_DIR="lambda"
ZIP_FILE="$BUILD_DIR/custodian_lambda.zip"

mkdir -p "$BUILD_DIR"

# Use Docker to build in Amazon Linux compatible env
docker run --rm -v "$PWD/$LAMBDA_DIR":/var/task -w /var/task \
  public.ecr.aws/lambda/python:3.9 \
  /bin/bash -c "
    pip install -r requirements.txt -t ./package && \
    cp handler.py custodian-policy.yml ./package && \
    cd package && \
    zip -r9 ../custodian_lambda.zip ."

mv "$LAMBDA_DIR/custodian_lambda.zip" "$BUILD_DIR/"
echo "✅ Lambda package built at $ZIP_FILE"
