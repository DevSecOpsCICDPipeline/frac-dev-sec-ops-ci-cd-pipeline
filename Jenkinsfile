            pipeline{
                agent any
                
                tools{
                    maven "Maven_3.9.6"
                }

            environment {
            NVD_API_KEY = credentials('nvd-api-key') // Bind secret text
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

                    stage('Dependency Scanning'){
                    parallel{
                    stage('Dependency Audit'){
                        steps{
                            sh 'echo checking Dependency Audit'
                        }
                    }

                    stage('OWASP Dependency Check'){
                        steps{
                        // dependencyCheck additionalArguments: '--scan ./ --format XML ', odcInstallation: 'DC_9'
                        dependencyCheck additionalArguments: '''
                        --scan \'./\'
                        --out \'./\'
                        --format \'ALL\'
                        --prettyPrint''', nvdCredentialsId: '$NVD_API_KEY',odcInstallation: 'DC_9'
                        }
                    }
                    }
                    }

            
                }
            }