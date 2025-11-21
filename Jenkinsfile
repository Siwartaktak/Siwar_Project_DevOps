pipeline {
agent any

```
environment {
    JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
    M2_HOME = '/usr/share/maven'
    PATH = "${JAVA_HOME}/bin:${M2_HOME}/bin:${env.PATH}"
    DOCKER_IMAGE = 'student-management:latest'
    NEXUS_REPO_SNAPSHOT = 'nexus-snapshots'
    NEXUS_REPO_RELEASE = 'nexus-releases'
    K8S_NAMESPACE = 'student-management'
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
            sh '''
                mvn sonar:sonar \
                    -Dsonar.host.url=http://192.168.56.10:9000/ \
                    -Dsonar.login=squ_860078581202612f9e2aa0d4cf28b0244169b95a
            '''
        }
    }

    stage('Publish to Nexus') {
        steps {
            sh '''
                mvn deploy -s settings.xml
            '''
        }
    }

    stage('Docker Build & Push') {
        steps {
            sh '''
                docker build -t $DOCKER_IMAGE .
                # Optionally tag for Nexus Docker registry if you have one
                # docker tag $DOCKER_IMAGE nexus:8082/$DOCKER_IMAGE:latest
                # docker push nexus:8082/$DOCKER_IMAGE:latest
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

    stage('Terraform Setup') {
        steps {
            dir('terraform') {
                sh '''
                    terraform init
                    terraform apply -auto-approve
                '''
            }
        }
    }

    stage('Kubernetes Deployment') {
        steps {
            sh '''
                # Make sure kubeconfig is pointing to your cluster
                export KUBECONFIG=~/.kube/config
                kubectl apply -f k8s/
                kubectl rollout status deployment/student-management -n $K8S_NAMESPACE
            '''
        }
    }
}

post {
    success { echo 'Pipeline completed successfully!' }
    failure { echo 'Pipeline failed. Check the logs!' }
}
```

}
