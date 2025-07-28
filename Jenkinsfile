pipeline {
    agent any

    tools {
        maven 'Maven'           // Optional: if you’ve set up Maven in Jenkins Tools
        jdk 'JDK-17'            // Optional: define JDK if needed
    }

    environment {
        MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED"
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

        stage('Maven Compile') {
            steps {
                echo 'Maven Compile started'
                sh 'mvn compile'
            }
        }

        stage('Maven Test') {
            steps {
                echo 'Maven Test started'
                sh 'mvn test'
            }
        }

        stage('Trivy Scan') {
            steps {
                echo 'Trivy Scan started'
                sh 'trivy fs --format table --output trivy--filescanproject-output.txt .'
            }
        }

        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    def scannerHome = tool 'SonarScanner'  // Must match your Jenkins tool name
                    echo 'Sonar Analysis started'
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=To-Do-App-CI-CD \
                        -Dsonar.projectName=To-DO-App-CI-CD \
                        -Dsonar.java.binaries=. \
                        -Dsonar.exclusions=**/trivy--filescanproject-output.txt
                    """
                }
            }
        }


    }
}
