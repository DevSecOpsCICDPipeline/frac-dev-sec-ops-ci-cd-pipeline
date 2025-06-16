            pipeline {
              agent any

              tools {
                maven "Maven_3.9.6"
                nodejs 'NODEJS-24-2-0'
              }

              environment {
                NVD_API_KEY = credentials('nvd-api-key')
                SONAR_SCANNER_HOME = tool 'sonar-scanner-7.1.0'
              }

              stages {
                stage('Cleaning Workspace') {
                  steps {
                   cleanWs()
                  }
                }
                stage ('checkout SCM') {
                 steps {
               git branch: 'main', changelog: false, poll: false, url: 'https://github.com/DevSecOpsCICDPipeline/frac-dev-sec-ops-ci-cd-pipeline.git'
                 }
                }
                stage('Compiling Maven Code') {
                  steps {
                    sh 'mvn -N io.takari:maven:wrapper'
                    sh 'mvn clean compile'
                  }
                }

                stage('Test') {
                  steps {
                    sh 'mvn clean test jacoco:report -DskipTests=false'
                  }

                }
                stage("SAST - SonarQube") {
                  steps {
                    withSonarQubeEnv('sonarqube') {
                      sh ''' 
                      $SONAR_SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=frac-dev-sec-solar-system \
                                    -Dsonar.java.binaries=. \
                                    -Dsonar.projectKey=frac-dev-sec-solar-system \
                                    -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                      '''
                    }
                  }
                }

                stage("quality gate") {
                  steps {
                    script {
                      waitForQualityGate abortPipeline: false, credentialsId: 'Sonarqube-token'
                    }
                  }
                }
                stage('Building war file using Maven') {
                  steps {
                    sh 'mvn clean install -DskipTests=true'
                  }
                }
             stage('Dependency Scanning') {
                  parallel {
                    stage('Dependency Audit') {
                      steps {
                        sh 'echo checking Dependency Audit'
                      }
                    }

                    stage('OWASP Dependency Check') {
                      steps {
                        catchError(buildResult: 'SUCCESS', message: 'Oops!it will be fixed in future release', stageResult: 'UNSTABLE') {
                          dependencyCheck additionalArguments: "--scan ./ --format ALL --disableYarnAudit --prettyPrint --nvdApiKey ${NVD_API_KEY}", odcInstallation: 'dependency-check'
                          // dependencyCheckPublisher failedTotalCritical: 0, pattern: '**/dependency-check-report.xml', stopBuild: false                                   
                        }

                      }
                    }
                  }
                }

                    stage ('Building Docker Image'){
                        steps {
                        sh  'docker build -t slpavaniv/frac-spring-project:${BUILD_TAG} .'
                        }
                    }
                    stage("Image Scanning using TRIVY"){
                         steps{
                         sh '''
                         trivy image slpavaniv/frac-spring-project:${BUILD_TAG} \
                         --severity LOW,MEDIUM,HIGH \
                         --exit-code 0 \
                         --quiet \
                         --format json -o trivy-image-MEDIUM-results.json

                         trivy image slpavaniv/frac-spring-project:${BUILD_TAG} \
                         --severity CRITICAL \
                         --exit-code 0 \
                         --quiet \
                         --format json -o trivy-image-CRITICAL-results.json
                         '''
                        }
                        post{
                            always{
                                sh'''
                                trivy convert \
                                --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                                --output trivy-image-MEDIUM-results.html trivy-image-MEDIUM-results.json

                                trivy convert \
                                --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                                --output trivy-image-CRITICAL-results.html trivy-image-CRITICAL-results.json

                                  trivy convert \
                                --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
                                --output trivy-image-MEDIUM-results.xml trivy-image-MEDIUM-results.json

                                trivy convert \
                                --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
                                --output trivy-image-CRITICAL-results.xml trivy-image-CRITICAL-results.json
                                '''
                            }
                        }
                    }

                       stage ('Push Docker Image'){
                        steps {
                          withDockerRegistry(credentialsId: 'docker-hub-credentials', url:"") {
                             sh  'docker push  slpavaniv/frac-spring-project:${BUILD_TAG}'
                          }
                        }
                    }



                  stage ('QA testing Stage') {
                     steps {
                      sh '''
                      TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
                       -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
                      export DNS_NAME="$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname)"
                      export JENKINS_URL="http://$DNS_NAME:8080/"
                      '''
                      sh 'docker rm -f qacontainer'
                      sh 'docker run -d --name qacontainer -p 8089:8089 slpavaniv/frac-spring-project:${BUILD_TAG}'
                      sleep time: 60, unit: 'SECONDS'
                      retry(10) {
                      sh 'curl --silent http://ec2-44-192-132-199.compute-1.amazonaws.com:8089/jpetstore/ | grep JPetStore'
                    }
                  }
                }
                    
              }  // end steps 

              post {
                always {
                  junit allowEmptyResults: true, keepProperties: true, testResults: 'dependency-check-junit.xml'
                  junit allowEmptyResults: true, keepProperties: true, testResults: 'target/surefire-reports/*.xml'
                  junit allowEmptyResults: true, keepProperties: true, testResults: 'trivy-image-MEDIUM-results.xml'
                  junit allowEmptyResults: true, keepProperties: true, testResults: 'trivy-image-CRITICAL-results.xml'
                
                  publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: '.', reportFiles: 'dependency-check-report.html', reportName: 'Dependency Check HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                 
                  publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: 'target/surefire-reports', reportFiles: '*.xml', reportName: 'Unit Test HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                 
                  publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './', reportFiles: 'trivy-image-CRITICAL-results.html', reportName: 'Trivy Image Critical Vul Report', reportTitles: '', useWrapperFileDirectly: true])

                    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './', reportFiles: 'trivy-image-MEDIUM-results.html', reportName: 'Trivy Image MEDIUM Vul Report', reportTitles: '', useWrapperFileDirectly: true])
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