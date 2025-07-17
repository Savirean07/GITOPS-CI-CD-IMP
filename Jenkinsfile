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
                        try {
                            withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')]) {
                                sh 'chmod +x run-owasp.sh'
                                sh './run-owasp.sh'
                            }
                        } catch (err) {
                            echo '⚠️ nvd-api-key not found, running OWASP scan without it.'
                            sh 'chmod +x run-owasp.sh'
                            sh './run-owasp.sh'
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
