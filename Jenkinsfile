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
                stage('Checkout Feature Branch') {
    steps {
        git url: 'https://github.com/DevSecOpsCICDPipeline/frac-dev-sec-ops-ci-cd-pipeline.git',
            branch: 'feature/advanced-domos',
            changelog: false,
            poll: false,
            refspec: '+refs/heads/feature/advanced-domos:refs/remotes/origin/feature/advanced-domos'
    }
}
                // stage ('checkout SCM') {
                //  steps {
                //     git branch: 'feature/advanced-domos',
                //     url: 'https://github.com/DevSecOpsCICDPipeline/frac-dev-sec-ops-ci-cd-pipeline.git',
                //     refspec: '+refs/heads/feature/advanced-domos:refs/remotes/origin/feature/advanced-domos'
                //  }
                // }
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
                                                
                  publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './', reportFiles: 'trivy-image-CRITICAL-results.html', reportName: 'Trivy Image Critical Vul Report', reportTitles: '', useWrapperFileDirectly: true])

                    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, icon: '', keepAll: true, reportDir: './', reportFiles: 'trivy-image-MEDIUM-results.html', reportName: 'Trivy Image MEDIUM Vul Report', reportTitles: '', useWrapperFileDirectly: true])
                            }
                        }
                        
                    }                   
              }  // end steps 

              post {
                always {
                 
                }
              }
            }

