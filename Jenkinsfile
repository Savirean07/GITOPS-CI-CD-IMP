pipeline {
    agent any

    environment {
        SONARQUBE = 'sonarqube-server'  // Must match Jenkins SonarQube config
        DOCKERHUB_USER = 'your-dockerhub-username'
        IMAGE_NAME = 'todo-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/your-org/your-repo.git'
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                bat 'dependency-check.bat --project "To-Do-App" --scan . --format HTML'
            }
        }

        stage('Code Analysis - SonarQube') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    bat 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage('Docker Build') {
            steps {
                bat 'docker build -t %DOCKERHUB_USER%/%IMAGE_NAME%:latest .'
            }
        }

        stage('Trivy Scan') {
            steps {
                bat 'trivy image %DOCKERHUB_USER%/%IMAGE_NAME%:latest'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    bat '''
                    echo %PASS% | docker login -u %USER% --password-stdin
                    docker push %DOCKERHUB_USER%/%IMAGE_NAME%:latest
                    '''
                }
            }
        }
    }

    post {
        success {
            build job: 'To-Do-CD'  // Triggers CD pipeline after CI success
        }
    }
}
