pipeline {
    agent any

    environment {
        // --- Configuration (customize as needed) ---
        SONAR_HOST_URL          = 'http://localhost:9000'
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
                withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')]) {
                    sh 'chmod +x run-owasp.sh'
                    sh './run-owasp.sh'
                }
            }
        }

        stage('Lint Code (ESLint)') {
            steps {
                // Run ESLint to check for code quality issues
                sh 'npx eslint .'
            }
        }

        stage('Docker Build & Push') {
            steps {
                // Securely access the Docker Hub credentials only for this stage
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    script {
                        def DOCKER_IMAGE = "${DOCKERHUB_USER}/gitops-app"
                        sh """
                        docker build -t ${DOCKER_IMAGE}:${env.GIT_COMMIT.take(7)} .
                        echo ${DOCKERHUB_PASS} | docker login -u ${DOCKERHUB_USER} --password-stdin
                        docker push ${DOCKER_IMAGE}:${env.GIT_COMMIT.take(7)}
                        """
                    }
                }
            }
        }

        stage('Trivy Scan (Image Vulnerabilities)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    script {
                        def DOCKER_IMAGE = "${DOCKERHUB_USER}/gitops-app"
                        sh "trivy image ${DOCKER_IMAGE}:${env.GIT_COMMIT.take(7)}"
                    }
                }
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
                // Securely access the Argo CD token only for this stage
                withCredentials([string(credentialsId: 'argocd-token', variable: 'ARGOCD_TOKEN')]) {
                    sh """
                    curl -k -X POST ${ARGO_CD_SERVER}/api/v1/applications/${ARGO_CD_APP_NAME}/sync \
                    -H \"Authorization: Bearer ${ARGOCD_TOKEN}\"
                    """
                }
            }
        }
    }

    post {
        always {
            // The 'mail' step is commented out. To use it, you must configure an SMTP server
            // in Jenkins -> Manage Jenkins -> Configure System -> E-mail Notification.
            // mail to: 'jangidhimanshu47@gmail.com',
            //      subject: "Jenkins Job - ${currentBuild.fullDisplayName}",
            //      body: "Job finished with status: ${currentBuild.currentResult}"
            echo "Pipeline finished with status: ${currentBuild.currentResult}"
        }
    }
}
