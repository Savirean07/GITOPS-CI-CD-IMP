pipeline {
    agent any

    environment {
        IMAGE_NAME = 'himanshujangid/to-do-app'
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Git Checkout') {
            steps {
                git(
                    branch: 'main',
                    credentialsId: 'git-cred',
                    url: 'https://github.com/Savirean07/To-Do-App-CI-CD.git'
                )
            }
        }

        stage('Install Node Dependencies') {
            steps {
                echo 'Installing NPM dependencies...'
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running Node.js tests...'
                sh 'npm test || echo "⚠️ Tests failed or none defined"'
            }
        }

        stage('Trivy Scan (Filesystem)') {
            steps {
                echo 'Trivy Scan started'
                sh 'trivy fs --format table --output trivy--filescanproject-output.txt .'
            }
        }

        stage('Docker Build and Tag') {
            steps {
                script {
                    echo 'Docker Build and Tag started'
                    echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Trivy Docker Image Scan') {
            steps {
                echo 'Trivy Docker image scan started'
                sh "trivy image --format table --output trivy-image-scan.txt ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Image Push to Docker Hub') {
            steps {
                script {
                    echo 'Docker Push to Docker Hub started'
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            docker push ${IMAGE_NAME}:${IMAGE_TAG}
                            docker logout
                        '''
                    }
                }
            }
        }

        stage('Image Push to Azure Container Registry') {
            steps {
                script {
                    echo 'Docker Push to Azure Container Registry started'

                    def acrRegistry = 'todo1-fravf4hkffbshdbc.azurecr.io'
                    def acrImage = "${acrRegistry}/to-do-app:${IMAGE_TAG}"

                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${acrImage}"

                    withCredentials([usernamePassword(credentialsId: 'acr-cred', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
                        sh """
                            echo "$ACR_PASSWORD" | docker login ${acrRegistry} -u "$ACR_USERNAME" --password-stdin
                            docker push ${acrImage}
                            docker logout ${acrRegistry}
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to Kubernetes cluster'

                    withCredentials([file(credentialsId: 'K8-cred', variable: 'KUBECONFIG_FILE')]) {
                        sh '''
                            export KUBECONFIG=$KUBECONFIG_FILE
                            kubectl apply -f deployment-service.yml
                            kubectl rollout status deployment/to-do-app
                        '''
                    }
                }
            }
        }
    }
}
