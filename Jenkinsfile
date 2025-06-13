pipeline{
    agent any
    
    tools{
        maven "maven3"
    }
    
    stages{
        stage('mvn version'){
            steps{
                sh 'echo maven version'
                sh 'mvn --version'
            }
        }
        stage('Build'){
            steps{
                sh 'mvn clean install -DskipTests'
            }
        }
        
        stage('Test'){
            steps{
                sh 'mvn test'
            }
        }
    }
}