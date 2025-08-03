#!/bin/bash

# Navigate to the lambda module directory
cd "$(dirname "$0")"

# Create a temporary directory for packaging
mkdir -p package

# Copy the Python file to the package directory
cp lambda_function.py package/

# Install dependencies (if any)
pip install -r requirements.txt -t package/ 2>/dev/null || echo "No requirements.txt found, skipping package installation"

# Create the zip file
cd package
zip -r ../lambda_function.zip .

# Clean up
cd ..
rm -rf package

echo "Lambda function packaged to lambda_function.zip"
