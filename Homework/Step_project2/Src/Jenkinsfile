pipeline {
    agent { label 'worker' }

    environment {
        IMAGE_NAME = "di0geen/forstep2"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Pull the code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Run tests') {
            steps {
                script {
                    def result = sh(
                        script: 'docker run --rm $IMAGE_NAME:$IMAGE_TAG npm test',
                        returnStatus: true
                    )

                    if (result != 0) {
                        echo 'Tests failed'
                        error('Tests failed')
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
    }
}