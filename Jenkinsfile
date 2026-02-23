pipeline {
    agent any
    
    environment {
        // Tester provides these credentials in Jenkins
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_PASSWORD = credentials('dockerhub-password')
        IMAGE_NAME = "${DOCKERHUB_USERNAME}/flask-aws-monitor"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                git branch: 'main', url: 'https://github.com/Daniel-Shmatnik/rollingproject.git'
            }
        }
        
        stage('Parallel Checks') {
            parallel {
                stage('Linting') {
                    steps {
                        echo '=== Running Linting Checks ==='
                        sh '''
                            pip install flake8 --break-system-packages -q
                            echo "--- Flake8 Python Linting ---"
                            flake8 python/ --max-line-length=120 || true
                        '''
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        echo '=== Running Security Scans ==='
                        sh '''
                            pip install bandit --break-system-packages -q
                            echo "--- Bandit Python Security Scan ---"
                            bandit -r python/ || true
                        '''
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '=== Building Docker Image ==='
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                """
                echo "✓ Docker image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo '=== Pushing to Docker Hub ==='
                sh """
                    echo \${DOCKERHUB_PASSWORD} | docker login -u \${DOCKERHUB_USERNAME} --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                    docker logout
                """
                echo "✓ Image pushed to Docker Hub: ${IMAGE_NAME}:${IMAGE_TAG}"
                echo "✓ Image pushed to Docker Hub: ${IMAGE_NAME}:latest"
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline completed successfully!'
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "✓ All stages passed"
            echo "✓ Docker image available at:"
            echo "  https://hub.docker.com/r/\${DOCKERHUB_USERNAME}/flask-aws-monitor"
            echo ""
            echo "To run locally:"
            echo "  docker pull ${IMAGE_NAME}:latest"
            echo "  docker run -p 5001:5001 ${IMAGE_NAME}:latest"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        }
        failure {
            echo '❌ Pipeline failed! Check logs for details.'
        }
        always {
            echo 'Cleaning up local Docker images...'
            sh """
                docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                docker rmi ${IMAGE_NAME}:latest || true
            """
        }
    }
}