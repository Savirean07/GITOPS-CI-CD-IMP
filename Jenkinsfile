pipeline {

    agent any

    environment {

        IMAGE_NAME = 'your-dockerhub-username/my-app'

        SONARQUBE_SERVER = 'SonarQube'

    }

    stages {

        stage('Checkout Code') {

            steps {

                git 'https://github.com/Savirean07/GITOPS-CI-CD-IMP'

            }

        }

        stage('Dependency Check') {

            steps {

                sh './dependency-check.sh' // OWASP script

            }

        }

        stage('SonarQube Analysis') {

            steps {

                withSonarQubeEnv("${SONARQUBE_SERVER}") {

                    sh 'sonar-scanner'

                }

            }

        }

        stage('Build Docker Image') {

            steps {

                sh 'docker build -t $IMAGE_NAME:latest .'

            }

        }

        stage('Trivy Scan') {

            steps {

                sh 'trivy image $IMAGE_NAME:latest'

            }

        }

        stage('Push Docker Image') {

            steps {

                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {

                    sh 'echo $PASS | docker login -u $USER --password-stdin'

                    sh 'docker push $IMAGE_NAME:latest'

                }

            }

        }

        stage('Trigger CD Job') {

            steps {

                build job: 'CD-JOB'

            }

        }

    }

    post {

        success {

            mail to: 'jangidhimanshu47@gmail.com',

                 subject: "CI Success",

                 body: "Build passed successfully"

        }

        failure {

            mail to: 'jangidhimanshu47@gmail.com',

                 subject: "CI Failed",

                 body: "Build failed. Check Jenkins logs."

        }

    }

}

 
