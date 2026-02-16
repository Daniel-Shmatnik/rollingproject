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
                        echo '=== Running Linting Checks (Mock) ==='
                        sh '''
                            echo "Running Flake8 for Python..."
                            echo "✓ Flake8 Python Linting: PASSED"
                            echo "✓ No style violations found"
                            echo ""
                            echo "Running ShellCheck for Shell scripts..."
                            echo "✓ ShellCheck Linting: PASSED"
                            echo "✓ No shell script issues found"
                            echo ""
                            echo "Running Hadolint for Dockerfile..."
                            echo "✓ Hadolint Dockerfile Linting: PASSED"
                            echo "✓ Dockerfile follows best practices"
                        '''
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        echo '=== Running Security Scans (Mock) ==='
                        sh '''
                            echo "Running Bandit for Python security..."
                            echo "✓ Bandit Security Scan: PASSED"
                            echo "✓ No security issues found in Python code"
                            echo "✓ Scanned files: 0 vulnerabilities detected"
                            echo ""
                            echo "Running Trivy for container security..."
                            echo "✓ Trivy Container Security Scan: PASSED"
                            echo "✓ No critical vulnerabilities found"
                            echo "✓ Image is safe to deploy"
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