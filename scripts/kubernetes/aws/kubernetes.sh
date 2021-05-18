#!/bin/bash

PS3="Please select your choice: "
options=(
    "AWS CLI, install" \
    "AWS CLI, configure" \
    "AWS-EKS, install kubectl" \
    "AWS-EKS, uninstall kubectl" \
    "AWS-EKS, install eksctl" \
    "AWS-EKS, uninstall eksctl" \
    "AWS-EKS, connect" \
    "AWS-EKS, create dashboard" \
    "AWS-EKS, connect to the dashboard" \
    "AWS-ECR, login" \
    "AWS-ECR, create repository" \
    "AWS-ECR, describe repositories" \
    "AWS-ECR, list image tags" \
    "AWS-ECR, delete image" \
    "AWS-ECR, delete untagged images" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "AWS CLI, install")
            rm -f /tmp/awscli-exe-linux-x86_64.zip
            wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -P /tmp
            unzip -q /tmp/awscli-exe-linux-x86_64.zip -d $HOME
            sudo $HOME/aws/install --update

            break
            ;;

        "AWS CLI, configure")
            aws --version
            read -p 'Profile name [default]: ' PROFILE_NAME
            if [ -z "$PROFILE_NAME" ]; then
                PROFILE_NAME='default'
            fi
            aws configure --profile $PROFILE_NAME
            export AWS_PROFILE=$PROFILE_NAME
            aws sts get-caller-identity
            echo -e "===========\nRun\n$ export AWS_PROFILE='$PROFILE_NAME'\n==========="

            break
            ;;

        "AWS-EKS, install kubectl")
            sudo rm -rf $HOME/.kube
            curl -o ./kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
            chmod +x ./kubectl
            sudo mv ./kubectl /usr/local/bin/kubectl
            kubectl version --short --client

            break
            ;;

        "AWS-EKS, uninstall kubectl")
            sudo rm -f /usr/local/bin/kubectl
            sudo rm -rf $HOME/.kube

            break
            ;;

        "AWS-EKS, install eksctl")
            curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
            sudo mv /tmp/eksctl /usr/local/bin
            echo "eksctl version: $(eksctl version)"

            break
            ;;

        "AWS-EKS, uninstall eksctl")
            sudo rm /usr/local/bin/eksctl

            break
            ;;

        "AWS-EKS, connect")
            aws sts get-caller-identity
            aws eks list-clusters
            read -p 'Region: ' REGION
            read -p 'Cluster name: ' NAME
            aws eks --region $REGION update-kubeconfig --name $NAME
            kubectl get svc
            kubectl get pods --all-namespaces

            break
            ;;

        "AWS-EKS, create dashboard")
            kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
            kubectl get deployment metrics-server -n kube-system
            kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.5/aio/deploy/recommended.yaml
            kubectl apply -f ./scripts/kubernetes/aws/eks-admin-service-account.yaml

            break
            ;;

        "AWS-EKS, connect to the dashboard")
            kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
            echo -e '\nhttp://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login'
            kubectl proxy

            break
            ;;

        "AWS-ECR, login")
            read -p 'Region: ' REGION
            read -p 'Username: ' USER
            read -p 'Password-stdin: ' -s PASSWORD
            aws ecr get-login-password --region $REGION | docker login --username $USER --password-stdin $PASSWORD

            break
            ;;

        "AWS-ECR, create repository")
            read -p 'Repository name: ' NAME
            aws ecr create-repository --repository-name $NAME

            break
            ;;

        "AWS-ECR, describe repositories")
            aws ecr describe-repositories

            break
            ;;

        "AWS-ECR, list image tags")
            read -p 'Repository name: ' NAME
            aws ecr list-images --repository-name $NAME

            break
            ;;

        "AWS-ECR, delete image")
            read -p 'Repository name: ' NAME
            read -p 'Image tag: ' TAG
            aws ecr batch-delete-image --repository-name $NAME --image-ids imageTag=$TAG
            
            break
            ;;

        "AWS-ECR, delete untagged images")
            read -p 'Region: ' REGION
            read -p 'Repository [spark-py]: ' REPO
            if [ -z "$REPO" ]; then
                REPO='spark-py'
            fi
            IMAGES_TO_DELETE=$(aws ecr list-images --region $REGION --repository-name $REPO --filter "tagStatus=UNTAGGED" --query 'imageIds[*]' --output json)
            aws ecr batch-delete-image --region $REGION --repository-name $REPO --image-ids "$IMAGES_TO_DELETE" || true

            break
            ;;

        "Quit")
            break
            ;;
        *)
            echo "Invalid option"
            
            break
            ;;
    esac
done
