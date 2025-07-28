pipeline {
    agent any

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
              timeout(time: 2, unit: 'MINUTES') {
                echo 'Waiting for Sonar Quality Gate...'
                waitForQualityGate abortPipeline: true, credentialsId: 'sonar'
              }
            }
        }
        stage('Maven Package') {
            steps {
                echo 'Maven Package started'
                sh 'export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED" && mvn package'
            }
        }
        stage('Jar Publish') {
            steps {
                script{
                       echo '<--------------Jar Publish started-------------->'
                       def server = Artifactory.server('jfrog-artifactory')
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
                    buildInfo.env.collect()
                    server.publishBuildInfo(buildInfo)
                    echo '<--------------Jar Publish completed-------------->' 
                }
            }
        }
        

    }
}
