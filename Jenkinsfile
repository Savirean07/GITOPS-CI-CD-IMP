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
                sh 'export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED" && mvn test'
            }
        }
        stage('trivy Scan') {
            steps {
                echo 'Trivy Scan started'
                sh 'trivy fs --format table --output trivy--filescanproject-output.txt .'
            }
        }
        stage('Sonar Analysis') {
            tools {
                sonarScanner 'SonarScanner'  // This must match the name configured in Jenkins > Global Tool Configuration
            }
            steps {
                withSonarQubeEnv('sonar') {
                    echo 'Sonar Analysis started'
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=To-Do-App-CI-CD \
                        -Dsonar.projectName=To-DO-App-CI-CD \
                        -Dsonar.java.binaries=. \
                        -Dsonar.exclusions=**/trivy--filescanproject-output.txt
                    '''
                }
            }
        }

    }
}
