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
                    
                    stage('Dependency Scanning'){
                    parallel{
                    stage('Dependency Audit'){
                        steps{
                            sh 'echo checking Dependency Audit'
                        }
                    }

                    stage('OWASP Dependency Check'){
                        steps{
                        catchError(buildResult: 'SUCCESS', message: 'Oops!it will be fixed in future release', stageResult: 'UNSTABLE') {
                        dependencyCheck additionalArguments: "--scan ./ --format ALL --prettyPrint --nvdApiKey ${NVD_API_KEY}", odcInstallation: 'dependency-check'
                        // dependencyCheckPublisher failedTotalCritical: 0, pattern: '**/dependency-check-report.xml', stopBuild: false                                   
                            }
                      
                        }
                    }
                    }
                    }

                        stage('Test'){
                        steps{
                            sh 'mvn test'
                            
                        }
                         
                      
                    }

            
                }

                post{
                    always{
                         junit allowEmptyResults: true, keepProperties: true, testResults: 'dependency-check-junit.xml'
                         junit allowEmptyResults: true, keepProperties: true, testResults: 'target/surefire-reports/*.xml'
                         publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: '.', reportFiles: 'dependency-check-report.html', reportName: 'Dependency Check HTML Report', reportTitles: '', useWrapperFileDirectly: true])     
                          publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'target/surefire-reports', reportFiles: '*.xml', reportName: 'Unit Test HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                    }
                }
            }