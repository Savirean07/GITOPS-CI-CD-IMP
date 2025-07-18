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
                script {
                    if (fileExists('dependency-check.sh')) {
                        sh './dependency-check.sh'
                    } else {
                        sh 'dependency-check --project "MyApp" --scan . --format HTML --out ./report'
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=MyApp \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
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
                sh 'trivy image $IMAGE_NAME:latest || true'  // avoid pipeline failure on low severity issues
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo $PASS | docker login -u $USER --password-stdin
                        docker push $IMAGE_NAME:latest
                    '''
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
