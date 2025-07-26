pipeline{
    agent any
    stages{
        stage('Git Checkout')(
            steps 
            {
                git branch: 'main',credentialsId: 'git-cred', url: 'https://github.com/Savirean07/To-Do-App-CI-CD.git
            }
        )
    }
  }