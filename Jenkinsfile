pipeline {
    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        M2_HOME = '/usr/share/maven'
        PATH = "${JAVA_HOME}/bin:${M2_HOME}/bin:${env.PATH}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Siwartaktak/Siwar_Project_DevOps.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh '''
                    docker build -t student-management:latest .
                '''
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Remove any existing containers with the same name
                    sh 'docker rm -f student-mysql || true'
                    // Bring up the containers
                    sh 'docker-compose up -d'
                }
            }
        }
    }

    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed. Check the logs!' }
    }
}
