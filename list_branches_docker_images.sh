#!/bin/bash

# Configuration
REPO_DIR=$(pwd) # Assumes the script is executed in the repository's directory
OUTPUT_FILE="branch_docker_images.txt"

# Ensure we are in a Git repository
if [[ ! -d ".git" ]]; then
    echo "Error: This script must be run in a Git repository."
    exit 1
fi

# Fetch the latest remote branches, including stale ones
git fetch --all --prune

# Initialize the output file
echo "Branch Name and Docker Image List (Including Stale Branches)" > "$OUTPUT_FILE"
echo "=============================================================" >> "$OUTPUT_FILE"

# Get a list of all remote branches, including stale ones
branches=$(git branch -r | grep -v '\->' | sed 's/origin\///')

# Process each branch
for branch in $branches; do
    echo "Processing branch: $branch"

    # Checkout the branch in a detached state
    git checkout "origin/$branch" &>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to checkout branch $branch"
        continue
    fi

    # Ensure the Jenkinsfile exists
    if [[ ! -f "Jenkinsfile" ]]; then
        echo "Warning: No Jenkinsfile found in branch $branch"
        echo "Branch Name: $branch" >> "$OUTPUT_FILE"
        echo "Docker Image: Not Found (No Jenkinsfile)" >> "$OUTPUT_FILE"
        echo "-------------------------------------------------------------" >> "$OUTPUT_FILE"
        continue
    fi

    # Extract TAG_NAME and APP_VERSION from Jenkinsfile
    TAG_NAME=$(grep "TAG_NAME =" Jenkinsfile | sed -n "s/.*TAG_NAME *= *['\"]\([^'\"]*\)['\"].*/\1/p")
    APP_VERSION=$(grep "APP_VERSION =" Jenkinsfile | sed -n "s/.*APP_VERSION *= *['\"]\([^'\"]*\)['\"].*/\1/p")

    # Check if values were extracted
    if [[ -z "$TAG_NAME" || -z "$APP_VERSION" ]]; then
        echo "Warning: Could not extract TAG_NAME or APP_VERSION in branch $branch"
        echo "Branch Name: $branch" >> "$OUTPUT_FILE"
        echo "Docker Image: Not Found (Malformed Jenkinsfile)" >> "$OUTPUT_FILE"
        echo "-------------------------------------------------------------" >> "$OUTPUT_FILE"
        continue
    fi

    # Compose the Docker image tag
    DOCKER_IMAGE="${TAG_NAME}:${APP_VERSION}"

    # Append the branch and Docker image to the output file
    echo "Branch Name: $branch" >> "$OUTPUT_FILE"
    echo "Docker Image: $DOCKER_IMAGE" >> "$OUTPUT_FILE"
    echo "-------------------------------------------------------------" >> "$OUTPUT_FILE"
done

# Checkout back to the main branch
git checkout main &>/dev/null

# Display the output file
echo "Docker image list created in $OUTPUT_FILE"
cat "$OUTPUT_FILE"

