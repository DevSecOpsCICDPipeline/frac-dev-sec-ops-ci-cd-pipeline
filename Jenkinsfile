pipeline{
    agent any
    
    tools{
        maven "Maven_3.9.6"
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

        stage('OWASP Dependency Check'){
            steps{
             dependencyCheck additionalArguments: '''
             --scan \'./\'
             --out \'./\'
             --format \'ALL\'
             --perttyPrint''', odcInstallation: 'DC_9'
            }
        }
    }
}