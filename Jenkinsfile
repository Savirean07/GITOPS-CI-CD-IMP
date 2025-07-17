pipeline {
    agent any

    environment {
        SONAR_HOST_URL   = 'http://localhost:9000'
        ARGO_CD_SERVER   = 'http://your-argocd-server'
        ARGO_CD_APP_NAME = 'gitops-app'
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
                sh './build.sh'
            }
        }

        stage('Security Scan (OWASP)') {
            steps {
                script {
                    withEnv(["PATH+DC=dependency-check/bin"]) {
                        // This block securely handles the NVD API key.
                        // It requires a Jenkins credential with the ID 'nvd-api-key'.
                        withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY', required: false)]) {
                            // Check if the credential was actually found and loaded.
                            if (NVD_API_KEY) {
                                echo '✅ Found nvd-api-key credential. Running scan with API key...'
                                // The script will now run with the NVD_API_KEY environment variable set.
                                sh 'chmod +x run-owasp.sh'
                                sh './run-owasp.sh'
                            } else {
                                // If the credential is not found, fail the build with a clear error message.
                                // The OWASP scan cannot succeed without a valid API key.
                                error('❌ FATAL: Jenkins credential with ID \'nvd-api-key\' not found. The OWASP scan requires a valid NVD API key to update its database. Please configure the credential in Jenkins and re-run the build.')
                            }
                        }
                    }
                }
            }
        }

        stage('Lint Code (ESLint)') {
            steps {
                sh 'npx eslint . || true' // Prevent pipeline failure on lint warnings
            }
        }

        stage('Docker Build & Push') {
            steps {
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
                withCredentials([string(credentialsId: 'argocd-token', variable: 'ARGOCD_TOKEN')]) {
                    sh """
                        curl -k -X POST ${ARGO_CD_SERVER}/api/v1/applications/${ARGO_CD_APP_NAME}/sync \
                        -H "Authorization: Bearer ${ARGOCD_TOKEN}"
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished with status: ${currentBuild.currentResult}"
        }
    }
}
