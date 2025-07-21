pipeline {
    agent any

    environment {
        SONARQUBE = 'sonarqube-server'  // Must match the name in Jenkins global config
        DOCKERHUB_USER = 'himanshujangid'
        IMAGE_NAME = 'todo-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Savirean07/GITOPS-CI-CD-IMP.git'
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                sh './dependency-check.sh --project "To-Do-App" --scan . --format HTML'
            }
        }

        stage('Code Analysis - SonarQube') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $DOCKERHUB_USER/$IMAGE_NAME:latest .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy image $DOCKERHUB_USER/$IMAGE_NAME:latest'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo $PASS | docker login -u $USER --password-stdin
                        docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
                    '''
                }
            }
        }
    }

    post {
        success {
            build job: 'To-Do-CD'  // Trigger CD pipeline (if set up)
        }
        failure {
            echo 'Build failed. Please check the logs.'
        }
    }
}
