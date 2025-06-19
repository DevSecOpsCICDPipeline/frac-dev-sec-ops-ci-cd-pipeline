 @Library('skyway-trusted-shared-library') _       
        
            pipeline {
              agent any

              tools {
                maven "Maven_3.9.6"
                nodejs 'NODEJS-24-2-0'
              }

              environment {
                NVD_API_KEY = credentials('nvd-api-key')
                SONAR_SCANNER_HOME = tool 'sonar-scanner-7.1.0'
                GIT_API_TOKEN = credentials('git-api-token')
                 TARGET_URL = "http://ec2-3-218-208-108.compute-1.amazonaws.com:8089/jpetstore/"
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
                    compileMaven() // custom step from vars/compileMaven.groovyle'
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
                           trivyScan.vulnerability("slpavaniv/frac-spring-project:${BUILD_TAG}")
                        }
                        post{
                            always{
                                trivyScan.reportsConverter()
                            }
                        }
                    }

                       stage ('Push Docker Image'){
                         when {
                branch pattern: "feature/.*", comparator: "REGEXP"
            }
                        steps {
                          withDockerRegistry(credentialsId: 'docker-hub-credentials', url:"") {
                             sh  'docker push  slpavaniv/frac-spring-project:${BUILD_TAG}'
                          }
                        }
                    }



                //   stage ('QA testing Stage') {
                //      steps {
                //       sh 'docker rm -f qacontainer'
                //       sh 'docker run -d --name qacontainer -p 8089:8089 slpavaniv/frac-spring-project:${BUILD_TAG}'
                //       sleep time: 60, unit: 'SECONDS'
                //       retry(2) {
                //       sh 'curl --silent http://ec2-44-192-132-199.compute-1.amazonaws.com:8089/jpetstore/ | grep JPetStore'
                //     }
                //   }
                // }

                
                stage ('K8S Update Image Tag'){
                   when {
                branch pattern: "feature/.*", comparator: "REGEXP"
            }
                  //  when {
                  //   branch 'main*'
                  //  }
                        steps {
                          sh 'echo K8S Update Image Tag'
                        //  sh 'git clone -b main https://github.com/DevSecOpsCICDPipeline/frac-dev-sec-ops-k8s.git'
                        //  dir("frac-dev-sec-ops-k8s/k8s"){
                        //   sh '''
                        //   #### Replace Docker Tag #####
                        //   git checkout main
                        //   git checkout -b feature-$BUILD_ID
                        //   sed -i "s#slpavaniv.*#slpavaniv/frac-spring-project:${BUILD_TAG}#g" deployment.yaml
                        //   cat deployment.yaml

                        //   #### Commit and Push to Feature Branch ####
                        //   git config --global user.email "ganislp@gmail.com"
                        //   git remote set-url origin https://ganislp:$GIT_API_TOKEN@github.com/DevSecOpsCICDPipeline/frac-dev-sec-ops-k8s.git
                        //   git add .
                        //   git commit -am "Updated docker image"
                        //   git push -u origin feature-$BUILD_ID
                        //   '''

                         }
                        }
                    
                    stage('K8S - Raise PR'){
                       when {
                branch pattern: "feature/.*", comparator: "REGEXP"
            }
                    //     when {
                    //   branch 'PR*'
                    // }
                    steps{
                      sh 'echo K8S - Raise PR'
                    //   sh '''
                    // curl -L \
                    // -X POST \
                    // -H "Accept: application/vnd.github+json" \
                    // -H "Authorization: Bearer $GIT_API_TOKEN" \
                    // -H "X-GitHub-Api-Version: 2022-11-28" \
                    //  https://api.github.com/repos/DevSecOpsCICDPipeline/frac-dev-sec-ops-k8s/pulls \
                    // -d '{"title":"Update Docker Image","body":"Updated docker image in deployment manifast","head":"feature-$BUILD_ID","base":"main"}'
                     
                    //   '''
                    }
                    }

                    stage('App Deployed?'){
                       when {
                branch pattern: "feature/.*", comparator: "REGEXP"
            }
                      steps{
                         sh 'echoApp Deployed?'
                        // timeout(time: 1,unit:'DAYS'){
                        //   input message: 'Is the PR Merged and ArgoCD Synced?',ok:'YES! PR is Merged and ArgoCD Application is Synced'

                        // }
                      }
                    }

                    stage('DAST -OWSP ZAP'){
                       when {
                branch pattern: "feature/.*", comparator: "REGEXP"
            }
                      steps{
                        sh 'echo DAST -OWSP ZAP'
                //         script {
                //     sh """
                //     sudo chmod -R 775 $WORKSPACE
                //     sudo chmod -R 777 $WORKSPACE
                //     // sudo chmod 777 $PWD
                //     docker run --rm \
                //       -v \$WORKSPACE:/zap/wrk/:rw \
                //       -t ghcr.io/zaproxy/zaproxy zap-baseline.py \
                //       -t $TARGET_URL \
                //       -c zap.yaml \
                //       -r zap-report.html
                //       -w zap_report.md
                //       -J zap_json-report.json
                //       -x zap_xml_report.xml
                //     """
                // }
                      //   sh '''
                      //  chmod -R 777 .
                      //   docker run --rm  -v ${pwd}:/zap/wrk/:rw owasp/zap2docker-stable zap-baseline.py \
                      //   -f http://ec2-3-235-53-12.compute-1.amazonaws.com:8089/jpetstore \
                      //   -r zap_report.html \
                      //   -w zap_report.md
                      //   -J zap_json-report.json
                      //   -x zap_xml_report.xml

                      //   '''
                      }
                    }
                    
              }  // end steps 

              post {
                always {

                  // script{
                  //   if(fileExists('frac-dev-sec-ops-k8s')){
                  //     sh 'rm -rf frac-dev-sec-ops-k8s'
                  //   }
                  // }


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
            // docker run -v $(WORKSPACE):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy zap-baseline.py -t http://ec2-3-218-208-108.compute-1.amazonaws.com:8089/jpetstore/ -r test-zap-report.html