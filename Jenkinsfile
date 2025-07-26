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

        stage('Maven Compile') {
            steps {
                echo 'Maven Compile started'
                sh 'export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED" && mvn compile'
            }
        }
        stage('Maven Test') {
            steps {
                echo 'Maven Test started'
                sh 'mvn test'
            }
        }
    }
}
