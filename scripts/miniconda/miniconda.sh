#!/bin/bash

PS3="Please select your choice: "
options=(
    "Miniconda 3, install" \
    "Recreate base environment" \
    "Update conda base" \
    "Clean" \
    "Miniconda 3, uninstall" \
    "Spyder, open" \
    "Jupyter notebook, start" \
    "Jupyter notebook, choose browser" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Miniconda 3, install")
            rm -f /tmp/Miniconda3-latest-Linux-x86_64.sh
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -P /tmp
            bash /tmp/Miniconda*.sh -b -p $HOME/miniconda
            
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda init bash
            conda config --add channels conda-forge
            conda update -y --all
            conda env update -f ./scripts/miniconda/environment.yml
            echo -e '===========\nRun the following command to restart environment variables: $ source $HOME/.bashrc\n==========='

            break
            ;;

        "Recreate base environment")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base && conda info --envs
            #conda env update --prune -f ./scripts/miniconda/environment.yml
            pip uninstall -y $(conda list | grep 'pypi' | awk -F' ' '{print $1}' | sed -E ':a;N;$!ba;s/\n/ /g')
            echo 'Installing revision 1, please wait.'
            conda install -y --revision 1
            conda env update -f ./scripts/miniconda/environment.yml
            conda clean -y --all
            echo -e "\nYou can check revisions running \$ conda list --revisions"

            break
            ;;

        "Update conda base")
            conda update -y -n base conda

            break
            ;;

        "Clean")
            conda clean -y --all

            break
            ;;
            
        "Miniconda 3, uninstall")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base
            conda clean -y --all
            conda init --reverse bash
            rm -rf $HOME/miniconda $HOME/.*conda*
            echo -e '===========\nRun the following command to restart environment variables: $ source $HOME/.bashrc\n==========='

            break
            ;;

        "Spyder, open")
            conda info --envs
            spyder 1> /dev/null 2>&1 &

            break
            ;;

        "Jupyter notebook, start")
            conda info --envs
            cd $HOME
            jupyter notebook

            break
            ;;

        "Jupyter notebook, choose browser")
            conda info --envs
            jupyter notebook --generate-config
            echo 'change c.NotebookApp.browser'
            echo 'Where is Firefox?'
            whereis firefox

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
