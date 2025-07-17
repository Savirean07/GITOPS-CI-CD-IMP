pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Savirean07/GITOPS-CI-CD-IMP.git'
            }
        }
        stage('Build') {
            steps {
                sh './build.sh'
            }
        }
        stage('Security Scan') {
            steps {
                sh './run-owasp.sh'
            }
        }
        stage('Code Quality') {
            steps {
                sh './run-sonarqube.sh'
            }
        }
    }
}
