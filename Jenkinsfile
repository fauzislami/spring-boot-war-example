pipeline {
    agent any
    
    tools {
        maven 'maven'
        jdk 'jdk8'
    }
 
    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "192.168.100.14:80"
        NEXUS_REPOSITORY = "maven-nexus-repo"
        NEXUS_CREDENTIAL_ID = "nexus-user-credentials"
    }

    stages {
        stage('Building code') {
            steps {
                sh 'mvn clean install'
                sh 'mvn -B -DskipTests clean package'
            }
        }

        stage('Unit testing') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                     catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                         junit 'target/surefire-reports/*.xml'
                     }
                }
            }
        }

        stage('Push artifact to Nexus') {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                 classifier: '',
                                 file: artifactPath,
                                 type: pom.packaging],
                                 [artifactId: pom.artifactId,
                                  classifier: '',
                                  file: "pom.xml",
                                  type: "pom"]
                                  
                                ]
                        );
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }
 
        stage('Build and Push Image') {
            script {
                docker.withRegistry('http://192.168.100.14:5000', 'nexus-user-credentials') {
                    def customImage = docker.build("192.168.100.14:5000/dev/hello-world:${env.BUILD_ID}")
                    customImage.push()
                }
            }
        }
        
        
    }
}
