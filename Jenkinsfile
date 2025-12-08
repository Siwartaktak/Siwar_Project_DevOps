pipeline {
    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        M2_HOME = '/usr/share/maven'
        PATH = "${JAVA_HOME}/bin:${M2_HOME}/bin:${env.PATH}"
        DOCKER_IMAGE = 'student-management:latest'
        NEXUS_REPO_SNAPSHOT = 'nexus-snapshots'
        NEXUS_REPO_RELEASE = 'nexus-releases'
        K8S_NAMESPACE = 'student-management'
        TERRAFORM_DIR = 'terraform'
        SONARQUBE_URL = 'http://192.168.56.10:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Siwartaktak/Siwar_Project_DevOps.git'
            }
        }

        stage('Build & Package') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // Wait for SonarQube to be ready (max 3 minutes)
                    def maxRetries = 36
                    def retryCount = 0
                    def sonarReady = false
                    
                    echo "Checking if SonarQube is ready..."
                    while (retryCount < maxRetries && !sonarReady) {
                        def statusCode = sh(
                            script: "curl -s -o /dev/null -w '%{http_code}' ${SONARQUBE_URL}/api/system/status || echo '000'",
                            returnStdout: true
                        ).trim()
                        
                        if (statusCode == '200') {
                            def status = sh(
                                script: "curl -s ${SONARQUBE_URL}/api/system/status | grep -o '\"status\":\"[^\"]*\"' || echo 'UNKNOWN'",
                                returnStdout: true
                            ).trim()
                            
                            if (status.contains('UP')) {
                                sonarReady = true
                                echo "✅ SonarQube is UP and ready!"
                            } else {
                                echo "⏳ SonarQube status: ${status}. Waiting... (${retryCount + 1}/${maxRetries})"
                                sleep 5
                            }
                        } else {
                            echo "⏳ SonarQube not ready yet (HTTP ${statusCode}). Waiting... (${retryCount + 1}/${maxRetries})"
                            sleep 5
                        }
                        retryCount++
                    }
                    
                    if (sonarReady) {
                        sh """
                            mvn sonar:sonar \
                                -Dsonar.host.url=${SONARQUBE_URL} \
                                -Dsonar.login=squ_fa1516551ff6d24d83ffc0188f62ef86d1ff4f1f
                        """
                    } else {
                        echo "⚠️ WARNING: SonarQube is not ready after 3 minutes. Skipping analysis."
                        echo "Check SonarQube logs: docker logs sonarqube"
                    }
                }
            }
        }

        stage('Publish to Nexus') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'mvn deploy -s settings.xml'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh '''
                    # Build image with local Docker
                    docker build --no-cache -t student-management:latest .
                    
                    # Load image into Minikube
                    minikube image load student-management:latest || echo "Minikube not available, skipping image load"
                '''
            }
        }

        stage('Deploy Docker') {
            steps {
                script {
                    sh 'docker rm -f student-mysql || true'
                    sh 'docker-compose up -d'
                }
            }
        }

        stage('Terraform Init & Validate') {
            when {
                expression { fileExists("${TERRAFORM_DIR}/main.tf") }
            }
            steps {
                script {
                    sh """
                        echo "=== Checking Terraform files ==="
                        ls -la ${TERRAFORM_DIR}/
                        
                        docker run --rm \
                            -v \${PWD}/${TERRAFORM_DIR}:/workspace \
                            -w /workspace \
                            hashicorp/terraform:latest \
                            init
                        
                        docker run --rm \
                            -v \${PWD}/${TERRAFORM_DIR}:/workspace \
                            -w /workspace \
                            hashicorp/terraform:latest \
                            validate
                    """
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { fileExists("${TERRAFORM_DIR}/main.tf") }
            }
            steps {
                script {
                    sh """
                        docker run --rm \
                            -v \${PWD}/${TERRAFORM_DIR}:/workspace \
                            -w /workspace \
                            hashicorp/terraform:latest \
                            plan -out=tfplan
                    """
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { fileExists("${TERRAFORM_DIR}/main.tf") }
            }
            steps {
                script {
                    sh """
                        docker run --rm \
                            -v \${PWD}/${TERRAFORM_DIR}:/workspace \
                            -w /workspace \
                            hashicorp/terraform:latest \
                            apply -auto-approve tfplan
                    """
                }
            }
        }

        stage('Kubernetes Deployment') {
            when {
                expression { fileExists('k8s') }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh '''#!/bin/bash
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        
                        echo "=== Applying Kubernetes manifests ==="
                        /usr/local/bin/kubectl apply -f k8s/ --validate=false
                        
                        echo "=== Checking deployment status ==="
                        /usr/local/bin/kubectl rollout status deployment/student-management -n student-management --timeout=2m || echo "Rollout check timed out"
                        
                        echo "=== Current pods status ==="
                        /usr/local/bin/kubectl get pods -n student-management || echo "Could not get pods"
                    '''
                }
            }
        }
    }
    
    post {
        success { 
            echo '✅ Pipeline completed successfully!' 
        }
        failure { 
            echo '❌ Pipeline failed. Check the logs!' 
        }
        unstable {
            echo '⚠️ Pipeline completed with warnings'
        }
        always {
            echo '🧹 Cleaning up...'
            sh 'docker system prune -f || true'
        }
    }
}