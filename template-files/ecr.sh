#!/bin/bash

: '
======================================
This Script allows to optimally the following:

  1. Add ECR tag to docker image
  2. Authenticate Docker client to your registry
  3. Push container with latest version into ECR

======================================
'

# Load environment variables from .env file
if [ -f ".env" ]; then
    while IFS='=' read -r key value
    do
        if [[ -n $key && -n $value ]]; then
            export "$key=$value"
        fi
    done < ".env"
else
    echo ".env file not found!"
    exit 1
fi

# Define the JSON file where the version is stored
VERSION_FILE="docker/version.json"

# Check if the version file exists and is not empty
if [ -f "$VERSION_FILE" ] && [ -s "$VERSION_FILE" ]; then
    # Attempt to fetch the current version
    CURRENT_VERSION=$(jq -r '.version' "$VERSION_FILE" 2>/dev/null)

    # Check if jq was successful in fetching a version
    if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "null" ]; then
        echo "Current version: $CURRENT_VERSION"
    else
        echo "Error reading version from $VERSION_FILE. Initializing with default version."
        initialize_version_file
    fi
else
    # Initialize the version file if it doesn't exist or is empty
    initialize_version_file
fi

# Prompt the user for a new version
read -r -p "Enter new version tag: " NEW_VERSION

# Update the version in the JSON file
echo "{\"version\": \"$NEW_VERSION\"}" > "$VERSION_FILE"

echo "$NEW_VERSION"

# Tag Container
docker tag serviform:latest "$AWS_ACCOUNT_NUMBER".dkr.ecr.eu-central-1.amazonaws.com/serviform-api-proxy:"$NEW_VERSION";

# Authenticate Docker client to your registry
aws ecr get-login-password --region "$REGION" | docker \
login --username AWS --password-stdin "$AWS_ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com;

# Push Container to ECR
docker push "$AWS_ACCOUNT_NUMBER".dkr.ecr.eu-central-1.amazonaws.com/serviform-api-proxy:"$NEW_VERSION"