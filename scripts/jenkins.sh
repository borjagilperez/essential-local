#!/bin/bash

PS3="Please select your choice: "
options=(
    "Install" \
    "AWS-EC2 Jenkins host, install components" \
    "Enable Docker and DockerHub" \
    "AWS CLI, configure" \
    "Enable Docker and AWS-ECR" \
    "Enable Airflow Helm Chart" \
    "Deploy key" \
    "Show deploy key" \
    "Run tunnel to Jenkins local port" "Test key" \
    "Unintall" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Install")
            wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
            sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
            sudo apt-get update && sudo apt-get install -y jenkins
            sudo sed -i -E "s/HTTP_PORT=.*/HTTP_PORT=9090/g" /etc/default/jenkins
            sudo systemctl restart jenkins
            sudo systemctl status jenkins
            echo -e "\nVisit http://localhost:9090 in the browser"

            break
            ;;

        "AWS-EC2 Jenkins host, install components")
            # jq and Helm
            sudo apt-get install -y jq snapd unzip wget
            sudo snap install helm --classic

            # Vault
            rm -f /tmp/vault_1.7.1_linux_amd64.zip
            wget https://releases.hashicorp.com/vault/1.7.1/vault_1.7.1_linux_amd64.zip -P /tmp
            sudo unzip -q /tmp/vault_1.7.1_linux_amd64.zip -d /usr/local/bin
            sudo chmod +x /usr/local/bin/vault

            # AWS CLI
            rm -f /tmp/awscli-exe-linux-x86_64.zip
            wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -P /tmp
            unzip -q /tmp/awscli-exe-linux-x86_64.zip -d $HOME
            sudo $HOME/aws/install --update

            # kubectl
            curl -o ./kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
            chmod +x ./kubectl
            sudo mv ./kubectl /usr/local/bin
            kubectl version --short --client

            # airflow-stable Helm chart
            sudo su -s /bin/bash jenkins -c "export PATH=/snap/bin:$PATH && helm repo add airflow-stable https://airflow-helm.github.io/charts && helm repo update && helm repo list && helm show chart airflow-stable/airflow"

            # Docker
            sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
            sudo usermod -aG docker $USER
            sudo systemctl enable docker
            systemctl list-unit-files | grep docker
            sudo systemctl start docker
            sudo usermod -aG docker jenkins
            docker --version
            echo -e '===========\nYou might need to reboot the operating system\n==========='

            break
            ;;

        "Enable Docker and DockerHub")
            sudo usermod -aG docker jenkins
            sudo su -s /bin/bash jenkins -c "docker login"
            sudo systemctl restart jenkins

            break
            ;;

        "AWS CLI, configure")
            sudo su -s /bin/bash jenkins -c 'aws --version'
            read -p 'Profile name [default]: ' PROFILE_NAME
            if [ -z "$PROFILE_NAME" ]; then
                PROFILE_NAME='default'
            fi
            sudo su -s /bin/bash jenkins -c "aws configure --profile $PROFILE_NAME"
            sudo su -s /bin/bash jenkins -c "export AWS_PROFILE=$PROFILE_NAME && aws sts get-caller-identity"
            echo -e "===========\nAfter switching to user jenkins, run\n$ export AWS_PROFILE='$PROFILE_NAME'\n==========="

            break
            ;;

        "Enable Docker and AWS-ECR")
            sudo usermod -aG docker jenkins
            read -p 'Profile name [default]: ' PROFILE_NAME
            if [ -z "$PROFILE_NAME" ]; then
                PROFILE_NAME='default'
            fi
            read -p 'Region: ' REGION
            read -p 'Username: ' USER
            read -p 'Password-stdin: ' -s PASSWORD
            sudo su -s /bin/bash jenkins -c "export AWS_PROFILE=$PROFILE_NAME && aws ecr get-login-password --region $REGION | docker login --username $USER --password-stdin $PASSWORD"
            sudo systemctl restart jenkins

            break
            ;;

        "Enable Airflow Helm Chart")
            sudo su -s /bin/bash jenkins -c "export PATH=/snap/bin:$PATH && helm repo add airflow-stable https://airflow-helm.github.io/charts && helm repo update && helm repo list && helm show chart airflow-stable/airflow"

            break
            ;;

        "Deploy key")
            sudo su -s /bin/bash jenkins -c "whoami && ssh-keygen -t rsa"
            echo 'Copy and paste the deploy key below. For example, if you are using GitHub visit https://github.com/<user>/<repo>/settings/keys'
            sudo cat /var/lib/jenkins/.ssh/id_rsa.pub

            break
            ;;

        "Show deploy key")
            sudo su -s /bin/bash jenkins -c "whoami"
            sudo cat /var/lib/jenkins/.ssh/id_rsa.pub

            break
            ;;

        "Run tunnel to Jenkins local port")
            # Create/update a webhook with it.
            # For example, in GitHub add a webhook with payload url https://<id>.ngrok.io/github-webhook/
            ngrok http localhost:9090

            break
            ;;

        "Unintall")
            sudo apt-get purge -y jenkins

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
