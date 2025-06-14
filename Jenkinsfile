            pipeline{
                agent any
                
                tools{
                    maven "Maven_3.9.6"
                }

                environment {
                     NVD_API_KEY = credentials('nvd-api-key')
                     SONAR_SCANNER_HOME = tool 'sonar-scanner-7.1.0'
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
                        stage("SAST - SonarQube"){
                                    steps{
                                            sh ''' 
                                        $SONAR_SCANNER_HOME/bin/sonar-scanner 
                                        -Dsonar.projectKey=frac-dev-sec-solar-system \
                                        -Dsonar.java.binaries=. \
                                        -Dsonar.host.url=http://ec2-44-214-89-229.compute-1.amazonaws.com:9000 \
                                        -Dsonar.login=sqp_d85607ace1beeba2193f628068e73f8bfbbe0295
                                            '''
                                        
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



//             		Analyze "frac-dev-sec-solar-system": sqp_e5509bc288936e4e951e53e47c0f40e340f1cbb4
// 		mvn clean verify sonar:sonar \
//   -Dsonar.projectKey=frac-dev-sec-solar-system \
//   -Dsonar.host.url=http://ec2-44-214-89-229.compute-1.amazonaws.com:9000 \
//   -Dsonar.login=squ_2e2313ed15183148b2a2c6873e494a7fc9858996


// mvn clean verify sonar:sonar \
//   -Dsonar.projectKey=frac-dev-sec-solar-system \
//   -Dsonar.host.url=http://ec2-44-214-89-229.compute-1.amazonaws.com:9000 \
//   -Dsonar.login=sqp_d85607ace1beeba2193f628068e73f8bfbbe0295