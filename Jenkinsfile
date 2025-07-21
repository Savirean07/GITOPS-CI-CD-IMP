pipeline {
    agent any

    environment {
        SONARQUBE = 'sonarqube-server'            // Must match Jenkins → Global Tool Config
        DOCKERHUB_USER = 'himanshujangid'
        IMAGE_NAME = 'todo-app'
    }

    tools {
        maven 'Maven 3.8.6'                        // Adjust based on your Jenkins Maven config
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Savirean07/GITOPS-CI-CD-IMP.git'
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                sh '''
                    mkdir -p owasp-reports
                    ./dependency-check.sh --project "To-Do-App" --scan . --format HTML --out owasp-reports
                '''
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
                sh '''
                    mkdir -p trivy-reports
                    trivy image --exit-code 0 --severity HIGH,CRITICAL --format table $DOCKERHUB_USER/$IMAGE_NAME:latest > trivy-reports/scan.txt
                '''
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
            echo '✅ Build succeeded! Triggering CD job...'
            build job: 'To-Do-CD'  // Optional: Trigger your CD pipeline
        }
        failure {
            echo '❌ Build failed. Check logs for details.'
        }
    }
}
