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
                // This script should contain your build commands, e.g., 'npm install'
                sh './build.sh'
            }
        }

        stage('Security Scan (OWASP)') {
            steps {
                // This script runs the OWASP dependency check.
                // The Jenkins agent needs to have dependency-check installed and configured.
                sh './run-owasp.sh'
            }
        }

        stage('Code Quality (SonarQube)') {
            steps {
                // This script runs the SonarQube scanner.
                // The Jenkins agent needs to have sonar-scanner installed and configured.
                sh './run-sonarqube.sh'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}











pipeline {
    agent any

    environment {
        SONAR_TOKEN = credentials('sonarqube-token')       // Create in Jenkins: Secret Text
        SONAR_HOST_URL = 'http://localhost:9000'   // Replace with your SonarQube URL
        DOCKER_IMAGE = 'yourdockerhubusername/gitops-app'  // Replace with your DockerHub image
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Savirean07/GITOPS-CI-CD-IMP.git'
            }
        }

        stage('Build') {
            steps {
                sh 'pwd'
                sh 'ls -l'
                sh './build.sh'
            }
        }

        stage('Security Scan (OWASP Dependency Check)') {
            steps {
                sh './run-owasp.sh'
            }
        }

        stage('Code Quality (SonarQube)') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh './run-sonarqube.sh'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh '''
                docker build -t $DOCKER_IMAGE:latest .
                echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
                docker push $DOCKER_IMAGE:latest
                '''
            }
        }

        stage('Trivy Scan (Image Vulnerabilities)') {
            steps {
                sh 'trivy image $DOCKER_IMAGE:latest'
            }
        }

        stage('Update GitHub Manifest') {
            steps {
                sh './update-manifest.sh'
            }
        }

        stage('Trigger Argo CD Sync') {
            steps {
                sh '''
                curl -k -X POST http://your-argocd-server/api/v1/applications/your-app/sync \
                -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN"
                '''
            }
        }
    }

    post {
        always {
            mail to: 'team@example.com',
                 subject: "Jenkins Job - ${currentBuild.fullDisplayName}",
                 body: "Job finished with status: ${currentBuild.currentResult}"
        }
    }
}
