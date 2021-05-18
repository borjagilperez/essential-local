#!/bin/bash

PS3="Please select your choice: "
options=(
    "OpenJDK 11, install" \
    "OpenJDK 8, install" \
    "Essential, install" \
    "Essential GUI, install" \
    "VirtualBox, install" \
    "Dropbox, install" \
    "TeamViewer, install" \
    "Connect your ngrok account (tunnel to localhost)" \
    "Upgrade and clean all" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "OpenJDK 11, install")
            sudo apt-get install -y openjdk-11-jdk openjdk-11-jre
            java -version
            echo >> $HOME/.bashrc
            echo '# Java OpenJDK 11' >> $HOME/.bashrc
            echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> $HOME/.bashrc
            echo 'export PATH=$JAVA_HOME/jre/bin:$PATH' >> $HOME/.bashrc
            sudo update-alternatives --config java
            echo -e '===========\nRun the following command to restart environment variables: $ source $HOME/.bashrc\n==========='

            break
            ;;

        "OpenJDK 8, install")
            sudo apt-get install -y openjdk-8-jdk openjdk-8-jre
            java -version
            echo >> $HOME/.bashrc
            echo '# Java OpenJDK 8' >> $HOME/.bashrc
            echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> $HOME/.bashrc
            echo 'export PATH=$JAVA_HOME/jre/bin:$PATH' >> $HOME/.bashrc
            sudo update-alternatives --config java
            echo -e '===========\nRun the following command to restart environment variables: $ source $HOME/.bashrc\n==========='

            break
            ;;

        "Essential, install")
            sudo apt-get install -y build-essential dos2unix curl git git-flow jq nano nmon snapd tree unzip wget
            sudo apt-get install -y openssh-client openssh-server

            # Scala
            wget https://www.scala-lang.org/files/archive/scala-2.12.10.deb -P /tmp
            sudo dpkg -i /tmp/scala-2.12.10.deb && sudo apt-get install -y --fix-broken
            scala -version
            # sbt
            echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
            curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
            sudo apt-get update && sudo apt-get install -y sbt

            # ngrok
            wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -P /tmp
            sudo unzip /tmp/ngrok-stable-linux-amd64.zip -d /usr/local/bin
            rm /tmp/ngrok-stable-linux-amd64.zip
            sudo chmod +x /usr/local/bin/ngrok
            ngrok version

            break
            ;;

        "Essential GUI, install")
            sudo apt-get install -y firefox firefox-locale-es gnome-disk-utility gparted pavucontrol redshift-gtk
            sudo apt-get install -y geany gitg terminator
            sudo snap install chromium
            sudo snap install zotero-snap
            sudo snap install code --classic
            sudo snap install intellij-idea-community --classic
            sudo snap install pycharm-community --classic
            sudo update-alternatives --config x-www-browser
            sudo update-alternatives --config x-terminal-emulator

            break
            ;;

        "VirtualBox, install")
            sudo apt-get install -y virtualbox virtualbox-ext-pack

            break
            ;;

        "Dropbox, install")
            sudo apt-get install -y nautilus-dropbox

            break
            ;;

        "TeamViewer, install")
            wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -P /tmp
            sudo dpkg -i /tmp/teamviewer_amd64.deb && sudo apt-get install -y --fix-broken

            break
            ;;

        "Connect your ngrok account (tunnel to localhost)")
            echo 'Connect with your ngrok account (tunnel to localhost) visiting https://ngrok.com'
            read -p 'ngrok authtoken: ' -s NGROK_TOKEN
            ngrok authtoken $NGROK_TOKEN

            break
            ;;

        "Upgrade and clean all")
            sudo apt-get update && sudo apt-get upgrade -y
            sudo apt-get autoremove -y && sudo apt-get autoclean

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
