pipeline {
    agent any

    environment {
        // --- Credentials (to be configured in Jenkins) ---
        // Note: You must create these credentials in your Jenkins instance.

        // ID of a 'Secret text' credential for your SonarQube token
        SONAR_TOKEN             = credentials('sonarqube-token')
        // ID of a 'Username with password' credential for Docker Hub
        DOCKERHUB_CREDENTIALS   = credentials('dockerhub-credentials')
        // ID of a 'Secret text' credential for your Argo CD auth token
        ARGOCD_AUTH_TOKEN       = credentials('argocd-token')

        // --- Configuration (customize as needed) ---
        SONAR_HOST_URL          = 'http://localhost:9000'
        // Use the username from the Docker Hub credential for the image name
        DOCKER_IMAGE            = "${DOCKERHUB_CREDENTIALS_USR}/gitops-app"
        ARGO_CD_SERVER          = 'http://your-argocd-server' // e.g., https://argocd.example.com
        ARGO_CD_APP_NAME        = 'gitops-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Savirean07/GITOPS-CI-CD-IMP.git'
            }
        }

        stage('Build') {
            steps {
                sh 'chmod +x build.sh'
                sh './build.sh' // Runs 'npm install'
            }
        }

        stage('Security Scan (OWASP)') {
            steps {
                sh 'chmod +x run-owasp.sh'
                sh './run-owasp.sh'
            }
        }

        stage('Code Quality (SonarQube)') {
            steps {
                sh 'chmod +x run-sonarqube.sh'
                withSonarQubeEnv('SonarQube') { // Assumes SonarQube is configured in Jenkins global config
                    sh './run-sonarqube.sh'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh """
                # Build the Docker image with the latest commit hash as the tag
                docker build -t ${DOCKER_IMAGE}:${env.GIT_COMMIT.take(7)} .
                # Log in to Docker Hub using the username and password from Jenkins credentials
                echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                # Push the image to Docker Hub
                docker push ${DOCKER_IMAGE}:${env.GIT_COMMIT.take(7)}
                """
            }
        }

        stage('Trivy Scan (Image Vulnerabilities)') {
            steps {
                // Scan the newly pushed Docker image for vulnerabilities
                sh "trivy image ${DOCKER_IMAGE}:${env.GIT_COMMIT.take(7)}"
            }
        }

        stage('Update GitHub Manifest') {
            steps {
                sh 'chmod +x update-manifest.sh'
                sh './update-manifest.sh'
            }
        }

        stage('Trigger Argo CD Sync') {
            steps {
                sh """
                # Trigger a sync in Argo CD to deploy the new version
                curl -k -X POST ${ARGO_CD_SERVER}/api/v1/applications/${ARGO_CD_APP_NAME}/sync \
                -H \"Authorization: Bearer ${ARGOCD_AUTH_TOKEN}\"
                """
            }
        }
    }

    post {
        always {
            // Send an email notification when the pipeline finishes
            mail to: 'jangidhimanshu47@gmail.com',
                 subject: "Jenkins Job - ${currentBuild.fullDisplayName}",
                 body: "Job finished with status: ${currentBuild.currentResult}"
        }
    }
}
