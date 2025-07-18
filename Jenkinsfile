pipeline {

    agent any

    environment {
        IMAGE_NAME = 'your-dockerhub-username/my-app'  // change to your Docker Hub image name
        SONARQUBE_SERVER = 'SonarQube'                 // Jenkins global tool config name
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/Savirean07/GITOPS-CI-CD-IMP'
            }
        }

        stage('Dependency Check (OWASP)') {
            steps {
                script {
                    try {
                        sh '''
                            dependency-check \
                            --project "MyApp" \
                            --scan . \
                            --format HTML \
                            --out ./report \
                            --disableAssembly
                        '''
                    } catch (err) {
                        echo "Dependency check failed: ${err}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
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

        stage('Trivy Vulnerability Scan') {
            steps {
                sh 'trivy image $IMAGE_NAME:latest || true'  // Don't fail build if scan finds vulnerabilities
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
                 subject: "✅ CI Pipeline Success",
                 body: "Your CI pipeline completed successfully. Docker image pushed and CD triggered."
        }

        failure {
            mail to: 'jangidhimanshu47@gmail.com',
                 subject: "❌ CI Pipeline Failed",
                 body: "Your CI pipeline failed. Check Jenkins logs for more info."
        }

        unstable {
            mail to: 'jangidhimanshu47@gmail.com',
                 subject: "⚠️ CI Pipeline Unstable",
                 body: "OWASP scan or other step failed, but pipeline continued. Please review the report."
        }
    }
}
