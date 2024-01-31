#!/bin/bash

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


# Assign the first command line argument to APP_NAME
APP_NAME=$1

# Check if APP_NAME is provided
if [ -z "$APP_NAME" ]; then
    echo "Please provide a project name:"
    read APP_NAME

    if [ -z "$APP_NAME" ]; then
        echo "No project name provided. Will create directories in the current path."
    else
        # Create the project directory and navigate into it
        mkdir "$APP_NAME"
        cd "$APP_NAME"
    fi
elif [ -n "$APP_NAME" ]; then
    # If APP_NAME is provided, create and navigate to the directory
    mkdir "$APP_NAME"
    cd "$APP_NAME"
fi

# Only execute the following if in the correct directory
if [ -z "$APP_NAME" ] || [ -n "$APP_NAME" ]; then
    # Create directories and files
    mkdir -p docs app/api app/info app/models app/services app/utils
    mkdir docker
    touch docker/Dockerfile docker/docker-compose.yml
    cp /Users/$USER/.scripts/template-files/ecr.sh docker/ecr.sh
    cp /Users/$USER/.scripts/template-files/Makefile Makefile
    mkdir tests
    touch tests/__init__.py
    touch .env README.md requirements.txt
    touch app/__init__.py app/database.py app/main.py
    touch app/api/__init__.py
    touch app/info/__init__.py app/info/appconfig.py
    touch app/models/__init__.py
    touch app/services/__init__.py
    touch app/utils/__init__.py
    

    # Append to README.md
    cat <<EOF >> README.md
# $APP_NAME

##  Setup
Follow these instructions to set up the project on your local development environment.

### Prerequisites

Before you begin, ensure you have installed:

- 

### Installation

1. **Install project dependencies**:


EOF

    # Append to requirements.txt
    cat <<EOF >> requirements.txt
fastapi
uvicorn
python-dotenv
EOF

    # Append to .gitignore
    cat <<EOF >> .gitignore
.env
EOF

    # Ask the user if they want to initialize a Git repository
    echo "Do you want to initialize a Git repository here? (y/n)"
    read init_git

    if [ "$init_git" = "y" ] || [ "$init_git" = "Y" ]; then
        git init
        echo "Git repository initialized."
    else
        echo "Skipping Git initialization."
    fi
fi
