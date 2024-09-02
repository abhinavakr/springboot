pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'abhinav2173/springboot:latest'
        DOCKER_CREDENTIALS_ID = 'dockerhub_id' // Replace with your Docker Hub credentials ID
        KUBECONFIG_CREDENTIALS_ID = 'jenkins-secretaa' // Replace with your Kubernetes config credentials ID
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

        stage('Create Deployment YAML') {
            steps {
                script {
                    echo 'Creating deployment.yaml file...'
                    writeFile file: 'deployment.yaml', text: '''
apiVersion: apps/v1
kind: Deployment
metadata:
  name: springboot-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: springboot-app
  template:
    metadata:
      labels:
        app: springboot-app
    spec:
      containers:
        - name: springboot-container
          image: ${DOCKER_IMAGE}
          ports:
            - containerPort: 8080
'''
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
                    withCredentials([
                        file(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBECONFIG'),
                        file(credentialsId: 'kube-client-cert', variable: 'CLIENT_CERT'),
                        file(credentialsId: 'kube-client-key', variable: 'CLIENT_KEY'),
                        file(credentialsId: 'kube-ca-cert', variable: 'CA_CERT')
                    ]) {
                        sh 'kubectl config use-context minikube'
                        sh '''
                            kubectl apply -f deployment.yaml \
                            --client-certificate=$CLIENT_CERT \
                            --client-key=$CLIENT_KEY \
                            --certificate-authority=$CA_CERT
                        '''
                        sh '''
                            kubectl apply -f service.yaml \
                            --client-certificate=$CLIENT_CERT \
                            --client-key=$CLIENT_KEY \
                            --certificate-authority=$CA_CERT
                        '''
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
