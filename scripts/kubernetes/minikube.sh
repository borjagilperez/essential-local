#!/bin/bash

PS3="Please select your choice: "
options=(
    "Install" \
    "Start" \
    "Stop" \
    "Stop and delete" \
    "Minikube, pull docker image" \
    "Minikube, prune docker images" \
    "Run tunnel to Minikube local URL" \
    "Uninstall" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Install")
            sudo curl -L https://storage.googleapis.com/minikube/releases/v1.17.1/minikube-linux-amd64 -o /usr/local/bin/minikube
            sudo chmod +x /usr/local/bin/minikube
            minikube version --short

            break
            ;;

        "Start")
            if hash virtualbox 2>/dev/null; then
                k8s_driver='virtualbox'
            else
                k8s_driver='docker'
            fi
            read -p 'Nodes [1]: ' k8s_nodes
            if [ -z "$k8s_nodes" ]; then
                k8s_nodes='1'
            fi
            read -p 'CPUs per node [2]: ' k8s_cpus
            if [ -z "$k8s_cpus" ]; then
                k8s_cpus='2'
            fi
            read -p 'Memory per node [8g]: ' k8s_memory
            if [ -z "$k8s_memory" ]; then
                k8s_memory='8g'
            fi
            read -p 'Disk size per node [12g]: ' k8s_disk_size
            if [ -z "$k8s_disk_size" ]; then
                k8s_disk_size='12g'
            fi
            minikube start \
                --addons metrics-server --addons dashboard \
                --driver $k8s_driver \
                --kubernetes-version=1.18.9 \
                --nodes $k8s_nodes \
                --cpus $k8s_cpus \
                --memory $k8s_memory \
                --disk-size $k8s_disk_size
            kubectl cluster-info

            tmp_dir=/tmp/minikube/dashboard
            rm -rf $tmp_dir && mkdir -p $tmp_dir
            minikube dashboard --url=true > $tmp_dir/minikube-dashboard.log 2>&1 &
            while [[ "$(cat $tmp_dir/minikube-dashboard.log)" != *"http://"* ]]; do
                sleep 5
            done
            cat $tmp_dir/minikube-dashboard.log

            break
            ;;

        "Stop")
            minikube stop

            break
            ;;

        "Stop and delete")
            minikube stop
            minikube delete

            break
            ;;

        "Minikube, pull docker image")
            eval $(minikube docker-env)
            docker login
            read -p 'Repository: ' NAME
            docker pull $NAME
            docker image ls
            eval $(minikube docker-env -u)

            break
            ;;

        "Minikube, prune docker images")
            eval $(minikube docker-env)
            docker image prune -f
            docker image ls
            eval $(minikube docker-env -u)

            break
            ;;

        "Run tunnel to Minikube local URL")
            ngrok http $(kubectl cluster-info | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | awk -F' ' 'NR==1{print $6; exit}')

            break
            ;;

        "Uninstall")
            minikube stop
            minikube delete
            docker stop $(docker ps -aq)
            sudo rm -rf $HOME/.kube $HOME/.minikube /usr/local/bin/minikube

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
