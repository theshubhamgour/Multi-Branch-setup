pipeline {
    agent any

    environment {
        TAG_NAME = 'theshubhamgour/made-changes'
        APP_VERSION = 'pre-release-v3.15.109'
        DOCKER_REPO = "${TAG_NAME}"
        DOCKER_TAG = "${APP_VERSION}"
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
