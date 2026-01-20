pipeline {
    agent {
        label 'kaniko' 
    }

    environment {
        DOCKER_HUB_USER = 'tuongndb1609'
    }

    stages {
        stage('Build Postgres') {
            when { changeset "postgres/**" }
            steps {
                container('kaniko') {
                    echo "--- Building Postgres ---"
                    sh """
                    /kaniko/executor --context ${WORKSPACE}/postgres \
                        --dockerfile ${WORKSPACE}/postgres/Dockerfile \
                        --destination ${DOCKER_HUB_USER}/noteonline-postgres:${env.BUILD_NUMBER} \
                        --destination ${DOCKER_HUB_USER}/noteonline-postgres:latest \
                        --cache=true --cleanup
                    """
                }
            }
        }

        stage('Build User Service') {
            when { changeset "user-service/**" }
            steps {
                container('kaniko') {
                    echo "--- Building User Service ---"
                    sh """
                    /kaniko/executor --context ${WORKSPACE}/user-service \
                        --dockerfile ${WORKSPACE}/user-service/Dockerfile \
                        --destination ${DOCKER_HUB_USER}/user-service:${env.BUILD_NUMBER} \
                        --destination ${DOCKER_HUB_USER}/user-service:latest \
                        --cache=true --cleanup
                    """
                }
            }
        }

        stage('Build Note Service') {
            when { changeset "note-service/**" }
            steps {
                container('kaniko') {
                    echo "--- Building Note Service ---"
                    sh """
                    /kaniko/executor --context ${WORKSPACE}/note-service \
                        --dockerfile ${WORKSPACE}/note-service/Dockerfile \
                        --destination ${DOCKER_HUB_USER}/note-service:${env.BUILD_NUMBER} \
                        --destination ${DOCKER_HUB_USER}/note-service:latest \
                        --cache=true --cleanup
                    """
                }
            }
        }

        // stage('SonarQube Analysis Frontend') {
        //     when { changeset "frontend/**" }
        //     steps {
        //         script {
        //             def scannerHome = tool 'sonar-scanner' 
        //             withSonarQubeEnv('SonarQubeServer') { 
        //                 dir('frontend') {
        //                     withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'TOKEN')]) {
        //                         sh """
        //                             ${scannerHome}/bin/sonar-scanner \
        //                             -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/build/** \
        //                             -Dsonar.projectKey=note-online-frontend \
        //                             -Dsonar.sources=. \
        //                             -Dsonar.host.url=http://sonarqube-sonarqube:9000 \
        //                             -Dsonar.login=${TOKEN}
        //                         """
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }

        stage('Build Frontend') {
            when { changeset "frontend/**" }
            steps {
                container('kaniko') {
                    echo "--- Building Frontend ---"
                    sh """
                    /kaniko/executor --context ${WORKSPACE}/frontend \
                        --dockerfile ${WORKSPACE}/frontend/Dockerfile \
                        --destination ${DOCKER_HUB_USER}/frontend:${env.BUILD_NUMBER} \
                        --destination ${DOCKER_HUB_USER}/frontend:latest \
                        --cache=true --cleanup
                    """
                }
            }
        }
        
        stage('Update Manifests') {
            when {
                anyOf {
                    changeset "frontend/**"
                    changeset "user-service/**"
                    changeset "note-service/**"
                    changeset "postgres/**"
                }
            }
            agent any
            steps {
                script {
                    def frontendChanged = currentBuild.changeSets.any { cs -> cs.items.any { it.affectedFiles.any { f -> f.path.startsWith('frontend/') } } }
                    def userChanged = currentBuild.changeSets.any { cs -> cs.items.any { it.affectedFiles.any { f -> f.path.startsWith('user-service/') } } }
                    def noteChanged = currentBuild.changeSets.any { cs -> cs.items.any { it.affectedFiles.any { f -> f.path.startsWith('note-service/') } } }
                    def postgresChanged = currentBuild.changeSets.any { cs -> cs.items.any { it.affectedFiles.any { f -> f.path.startsWith('postgres/') } } }

                    sh """
                        git config --global user.email 'tuongndb@gmail.com'
                        git config --global user.name 'Jenkins Bot'
                    """
                    def touched = []
                    if (frontendChanged) {
                        sh "sed -i 's|image: ${DOCKER_HUB_USER}/frontend:.*|image: ${DOCKER_HUB_USER}/frontend:${env.BUILD_NUMBER}|g' k8s-manifest/frontend.yaml"
                        touched << 'frontend'
                    }
                    if (userChanged) {
                        sh "sed -i 's|image: ${DOCKER_HUB_USER}/user-service:.*|image: ${DOCKER_HUB_USER}/user-service:${env.BUILD_NUMBER}|g' k8s-manifest/user-service.yaml"
                        touched << 'user-service'
                    }
                    if (noteChanged) {
                        sh "sed -i 's|image: ${DOCKER_HUB_USER}/note-service:.*|image: ${DOCKER_HUB_USER}/note-service:${env.BUILD_NUMBER}|g' k8s-manifest/note-service.yaml"
                        touched << 'note-service'
                    }
                    if (postgresChanged) {
                        sh "sed -i 's|image: ${DOCKER_HUB_USER}/noteonline-postgres:.*|image: ${DOCKER_HUB_USER}/noteonline-postgres:${env.BUILD_NUMBER}|g' k8s-manifest/postgres.yaml"
                        touched << 'postgres'
                    }

                    if (touched) {
                        withCredentials([usernamePassword(credentialsId: 'github-token', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                            sh """
                                git add k8s-manifest/*.yaml
                                git commit -m "chore: update image tags to build ${env.BUILD_NUMBER} [skip ci]" || true
                                git push https://${GIT_PASSWORD}@github.com/UIT-BaoTuong/note-online-microservices.git HEAD:main
                            """
                        }
                    } else {
                        echo 'No manifest changes needed.'
                    }
                }
            }
        }
    }
}