#!/bin/bash

PS3="Please select your choice: "
options=(
    "Install kubectl and Helm" \
    "Kubectl, print version" \
    "Contexts info" \
    "Use context" \
    "Get Kubernetes master" \
    "Cluster information" \
    "Namespace info" \
    "Logs" \
    "Logs of last pod" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Install kubectl and Helm")
            # kubectl
            sudo snap install kubectl --channel=1.18/stable --classic
            echo "Kubectl $(kubectl version --short --client)"
            # Helm
            sudo snap install helm --classic

            break
            ;;

        "Kubectl, print version")
            kubectl version --short --client

            break
            ;;

        "Contexts info")
            kubectl config get-contexts
            kubectl config current-context

            break
            ;;

        "Use context")
            read -p 'Name: ' NAME
            kubectl config use-context $NAME

            break
            ;;

        "Get Kubernetes master")
            K8S_MASTER=$(kubectl cluster-info | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | awk -F' ' 'NR==1{print $6; exit}')
            echo $K8S_MASTER

            break
            ;;

        "Cluster information")
            kubectl cluster-info
            kubectl get nodes

            break
            ;;

        "Namespace info")
            read -p 'Namespace [default]: ' NAMESPACE
            if [ -z "$NAMESPACE" ]; then
                NAMESPACE='default'
            fi
            kubectl get -n $NAMESPACE all

            break
            ;;

        "Logs")
            read -p 'Namespace [default]: ' NAMESPACE
            if [ -z "$NAMESPACE" ]; then
                NAMESPACE='default'
            fi
            read -p 'Name: ' NAME
            kubectl logs -n $NAMESPACE $NAME

            break
            ;;

        "Logs of last pod")
            read -p 'Namespace [default]: ' NAMESPACE
            if [ -z "$NAMESPACE" ]; then
                NAMESPACE='default'
            fi
            kubectl logs -n $NAMESPACE $(kubectl get -n $NAMESPACE pods --sort-by=.metadata.creationTimestamp | awk -F' ' 'END{print $1}')

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
