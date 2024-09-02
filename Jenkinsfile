pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'abhinav2173/springboot:latest'
        DOCKER_CREDENTIALS_ID = 'dockerhub_id'          // Replace with your Docker Hub credentials ID
        KUBECONFIG_CREDENTIALS_ID = 'kube-client-cert'  // Replace with your Kubernetes config credentials ID
        GIT_CREDENTIALS_ID = 'your-git-credentials-id'  // Replace with your Git credentials ID, if required
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo 'Checking out the source code...'
                    checkout([$class: 'GitSCM', 
                        branches: [[name: '*/main']],  // Replace 'main' with your actual branch name if different
                        userRemoteConfigs: [[url: 'https://github.com/abhinavakr/springboot.git',
                                             credentialsId: GIT_CREDENTIALS_ID]]])
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    echo 'Building the Docker image...'
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    echo 'Logging into Docker Hub...'
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo 'Pushing the Docker image to Docker Hub...'
                    sh "docker push ${DOCKER_IMAGE}"
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
        image: abhinav2173/springboot:latest
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
    - protocol: TCP
      port: 80
      targetPort: 8080
'''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying the application to Kubernetes...'
                    withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG')]) {
                        sh 'kubectl apply -f deployment.yaml'
                        sh 'kubectl apply -f service.yaml'
                    }
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
