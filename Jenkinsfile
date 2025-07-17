pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Savirean07/GITOPS-CI-CD-IMP.git'
            }
        }
        stage('Build') {
            steps {
                sh 'pwd'
                sh 'ls -l'     // Optional debug
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
