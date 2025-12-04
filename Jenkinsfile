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
                sh """
                    mvn sonar:sonar \
                        -Dsonar.host.url=http://192.168.56.10:9000/ \
                        -Dsonar.login=squ_fa1516551ff6d24d83ffc0188f62ef86d1ff4f1f
                """
            }
        }

        stage('Publish to Nexus') {
            steps {
                sh 'mvn deploy -s settings.xml'
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh """
                    docker build -t $DOCKER_IMAGE .
                """
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
            steps {
                script {
                    sh """
                        echo "=== Checking Terraform files ==="
                        ls -la ${TERRAFORM_DIR}/ || echo "Terraform directory not found"
                        
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
           steps {
              sh '''#!/bin/bash
                 export KUBECONFIG=/var/lib/jenkins/.kube/config
                 /usr/bin/kubectl apply -f k8s/ --validate=false
                 /usr/bin/kubectl rollout status deployment/student-management -n student-management
              '''
    }
}
    
    post {
        success { 
            echo 'Pipeline completed successfully!' 
        }
        failure { 
            echo 'Pipeline failed. Check the logs!' 
        }
        always {
            sh 'docker system prune -f || true'
        }
    }
}