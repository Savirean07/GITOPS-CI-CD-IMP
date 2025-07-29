pipeline {
    agent any
    environment {
        IMAGE_NAME = 'himanshujangid/to-do-app'
        IMAGE_TAG = "latest"
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
                sh 'export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED" && mvn compile'
            }
        }
        stage('Maven Test') {
            steps {
                echo 'Maven Test started'
                sh 'export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED" && mvn test'
            }
        }
        stage('trivy Scan') {
            steps {
                echo 'Trivy Scan started'
                sh 'trivy fs --format table --output trivy--filescanproject-output.txt .'
            }
        }
        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    script {
                        def scannerHome = tool name: 'SonarScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
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
        stage('Sonar Quality Gate') {
            steps {
              timeout(time: 1, unit: 'MINUTES') {
                echo 'Waiting for Sonar Quality Gate...'
                waitForQualityGate abortPipeline: true, credentialsId: 'sonar'
              }
            }
        }
        stage('Maven Package') {
            steps {
                echo 'Maven Package started'
                sh 'export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED" && mvn package'
                sh 'ls -lh target/'
            }
        }
        stage('Jar Publish') {
            steps {
                script{
                       echo '<--------------Jar Publish has started------------------>'
                       def server = Artifactory.server('jfrog-artifactory')
                       def commitId = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                       def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                       def uploadSpec = """{
                            "files": [
                              {
                                "pattern": "target/database_service_project.jar",
                                "target": "to-do-app-libs-release/",
                                "flat": "false",
                                "props" : "${properties}"
                           }
                        ]
                    }"""
                    def buildInfo = server.upload(uploadSpec)
                    server.publishBuildInfo(buildInfo)
                    echo '<--------------Jar Publish has completed------------------>' 
                }
            }
        }
        
        stage('Docker Build and Tag') {
            steps {
                script{
                    echo 'Docker Build and Tag started'
                    echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Trivy Docker Image Scan') {
            steps{
                echo 'Trivy Docker image scan started'
                sh "trivy image --format table --output trivy-image-scan.txt ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Image Push to Docker Hub') {
            steps {
                script {
                   echo 'Docker Push to Docker Hub started'

                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]){
                        sh '''
                         echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                         docker push ${IMAGE_NAME}:${IMAGE_TAG}
                         docker logout
                     '''
                    }
                }
            }
        }
        stage('Image Push to Azure Container Registry') {
            steps {
                script {
                       echo 'Docker Push to Azure Container Registry started'

                       def acrRegistry = 'todo1-fravf4hkffbshdbc.azurecr.io'
                       def acrImage = "${acrRegistry}/to-do-app:${IMAGE_TAG}"

                       // Retag image for ACR
                       sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${acrImage}"

                      // Login and push to ACR
                      withCredentials([usernamePassword(credentialsId: 'acr-cred', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
                      sh """
                        echo "$ACR_PASSWORD" | docker login ${acrRegistry} -u "$ACR_USERNAME" --password-stdin
                        docker push ${acrImage}
                        docker logout ${acrRegistry}
                      """
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to Kubernetes cluster'
                    
                    withCredentials([file(credentialsId: 'K8-cred', variable: 'KUBECONFIG_FILE')]) {
                        sh '''
                            export KUBECONFIG=$KUBECONFIG_FILE
                            kubectl apply -f deployment-service.yml
                            kubectl rollout status deployment/to-do-app
                        '''
                    }
                }
            }
        }
    }
}