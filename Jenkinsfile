pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Savirean07/GITOPS-CI-CD-IMP.git'
        MANIFEST_FILE = 'k8s/deployment.yaml'
        NEW_IMAGE_TAG = 'latest'
        ARGOCD_APP = 'my-app'  // Argo CD app name
    }

    stages {

        stage('Checkout Manifest Repo') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Update Manifest with New Image') {
            steps {
                sh """
                    sed -i 's|image: .*|image: your-dockerhub-username/my-app:${NEW_IMAGE_TAG}|' ${MANIFEST_FILE}
                    git config user.name "jenkins"
                    git config user.email "jenkins@example.com"
                    git add ${MANIFEST_FILE}
                    git commit -m "Update image tag to ${NEW_IMAGE_TAG} from Jenkins CD"
                    git push origin main
                """
            }
        }

        stage('Trigger Argo CD Sync') {
            steps {
                withCredentials([string(credentialsId: 'argocd-auth-token', variable: 'ARGO_TOKEN')]) {
                    sh '''
                        curl -X POST https://argocd.example.com/api/v1/applications/${ARGOCD_APP}/sync \
                            -H "Authorization: Bearer $ARGO_TOKEN"
                    '''
                }
            }
        }
    }

    post {
        success {
            mail to: 'jangidhimanshu47@gmail.com',
                 subject: "✅ CD Pipeline Success",
                 body: "Deployment manifest updated and Argo CD sync triggered successfully."
        }

        failure {
            mail to: 'jangidhimanshu47@gmail.com',
                 subject: "❌ CD Pipeline Failed",
                 body: "CD pipeline failed. Check Jenkins logs for details."
        }
    }
}
