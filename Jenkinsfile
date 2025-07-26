pipeline {
    agent any

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

        stage('Build') {
            steps {
                echo 'Build steps go here.'
            }
        }

        stage('Test') {
            steps {
                echo 'Test steps go here.'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploy steps go here.'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
