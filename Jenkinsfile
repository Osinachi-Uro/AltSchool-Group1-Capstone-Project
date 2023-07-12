#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-west-1"
    }
    stages {
        stage("Create an EKS Cluster") {
            steps {
                script {
                    dir('Provision') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"        
                    }
                }
            }
        }

        stage("Deploy Prometheus and Grafana on EKS Cluster") {
            steps {
                script {
                    dir('Monitor') {
                        sh "aws eks --region eu-west-1 update-kubeconfig --name capstone-cluster"
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy Django School App to EKS") {
            steps {
                script {
                    dir('Deploy') {
                        sh "kubectl apply -f 01-namespace.yml"
                        sh "kubectl apply -f 02-persistent-volume.yml"
                        sh "kubectl apply -f 03-persistent-volume-claim.yml"
                        sh "kubectl apply -f 04-db-deployment.yml"
                        sh "kubectl apply -f 05-db-service.yml"
                        sh "kubectl apply -f 06-djanjo-deployment.yml"
                        sh "kubectl apply -f 07-djanjo-service.yml"
                        sh "kubectl apply -f 08-djanjo-job-migration.yml"
                    }
                }
            }
        }
    }
}
