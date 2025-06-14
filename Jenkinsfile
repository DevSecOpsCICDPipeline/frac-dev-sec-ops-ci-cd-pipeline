            pipeline{
                agent any
                
                tools{
                    maven "Maven_3.9.6"
                }

            environment {
            NVD_API_KEY = "eaeae46e-cd3c-479b-9c21-6bd85497f290" // Bind secret text
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
                    
                    // stage('Test'){
                    //     steps{
                    //         sh 'mvn test'
                    //     }
                    // }

                    stage('Dependency Scanning'){
                    parallel{
                    stage('Dependency Audit'){
                        steps{
                            sh 'echo checking Dependency Audit'
                        }
                    }

                    stage('OWASP Dependency Check'){
                        steps{
                            sh '''
                             dependencyCheck additionalArguments: "--scan ./ --format XML --nvdApiKey ${NVD_API_KEY}",
                                odcInstallation: 'DC_9'
                         '''
                        }
                    }
                    }
                    }

            
                }
            }