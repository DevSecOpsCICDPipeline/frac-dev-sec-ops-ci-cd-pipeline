            pipeline{
                agent any
                
                tools{
                    maven "Maven_3.9.6"
                }

                environment {
                     NVD_API_KEY = credentials('nvd-api-key')
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
                        dependencyCheck additionalArguments: "--scan ./ --format ALL --prettyPrint --nvdApiKey ${NVD_API_KEY}", odcInstallation: 'dependency-check'
                        }
                    }
                    }
                    }

            
                }
            }