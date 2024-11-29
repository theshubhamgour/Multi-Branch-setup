#!/bin/bash

# Configuration
BRANCH_COUNT=20
BASE_APP_VERSION="3.15.100"

# Ensure the repository is clean
if [[ -n $(git status --porcelain) ]]; then
    echo "The repository is not clean. Please commit or stash your changes before running this script."
    exit 1
fi

# Create unique APP_VERSION
increment_version() {
    IFS='.' read -r -a version <<< "$1"
    version[2]=$((version[2] + 1))
    echo "${version[0]}.${version[1]}.${version[2]}"
}

# Add folders, files, and Jenkinsfile to the main branch
echo "Setting up main branch..."

mkdir -p folder1/subfolder folder2/subfolder
echo "Sample content for file1" > folder1/file1.txt
echo "Sample content for file2" > folder2/file2.txt
for j in {1..10}; do
    echo "Content for file$j" > "file$j.txt"
done

git add .
git commit -m "Add base files and folder structure to main"
git push origin main

# Create branches from main with unique Jenkinsfile changes
current_version=$BASE_APP_VERSION

for ((i = 1; i <= BRANCH_COUNT; i++)); do
    branch_name="branch-$i"
    git checkout -b "$branch_name"

    # Create a Jenkinsfile with a unique APP_VERSION
    cat > Jenkinsfile <<EOF
pipeline {
    agent any

    environment {
        TAG_NAME = 'theshubhamgour/made-changes'
        APP_VERSION = 'pre-release-v${current_version}'
        DOCKER_REPO = "\${TAG_NAME}"
        DOCKER_TAG = "\${APP_VERSION}"
    }

    stages {
        stage('Check Docker Image') {
            steps {
                echo "Checking if Docker image exists..."
            }
        }
        stage('Build Image') {
            when {
                expression {
                    return true
                }
            }
            steps {
                echo "Building Docker image..."
            }
        }
        stage('Docker Push') {
            steps {
                echo "Pushing Docker image..."
            }
        }
        stage('Docker Cleanup') {
            steps {
                echo "Cleaning up Docker images..."
            }
        }
    }
}
EOF

    # Commit and push changes
    git add .
    git commit -m "Add Jenkinsfile with APP_VERSION ${current_version} for $branch_name"
    git push -u origin "$branch_name"

    # Increment version for the next branch
    current_version=$(increment_version "$current_version")
done

# Checkout back to main
git checkout main
echo "Branches created successfully."

