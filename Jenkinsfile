pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'abhinav2173/springboot:latest' // Replace 'latest' with your preferred tag
        DOCKER_CREDENTIALS_ID = 'dockerhub_id'
        KUBECONFIG_CREDENTIALS_ID = 'jenkins-secretaa' // Ensure this is correctly quoted
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo 'Building the Docker image...'
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Login') {
            steps {
                script {
                    echo 'Logging into Docker Hub...'
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        // Docker login is handled by this block
                    }
                }
            }
        }

        stage('Push') {
            steps {
                script {
                    echo 'Pushing the Docker image to Docker Hub...'
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        sh 'docker push ${DOCKER_IMAGE}'
                    }
                }
            }
        }

        stage('Create Service YAML') {
            steps {
                script {
                    echo 'Creating service.yaml file...'
                    writeFile file: 'service.yaml', text: '''
apiVersion: v1
kind: Service
metadata:
  name: springboot-service
spec:
  type: LoadBalancer
  selector:
    app: springboot-app
  ports:
    - port: 8080
      targetPort: 8080
'''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying the application to Kubernetes...'
                    withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBECONFIG')]) {
                        sh 'kubectl config use-context minikube'  // Set Minikube context
                        sh 'kubectl apply -f deployment.yaml --kubeconfig=$KUBECONFIG'
                        sh 'kubectl apply -f service.yaml --kubeconfig=$KUBECONFIG'
                    }
                }
            }
        }

        stage('Post Actions') {
            steps {
                script {
                    echo 'Cleaning up...'
                    sh 'docker system prune -af'
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}
