#!/bin/bash

PS3="Please select your choice: "
options=(
    "Install" \
    "Initialize" \
    "Start server" \
    "Unseal" \
    "Seal" \
    "Clean up" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Install")
            curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
            sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
            sudo apt-get update && sudo apt-get install vault
            vault version

            break
            ;;

        "Initialize")
            export VAULT_ADDR='http://127.0.0.1:8200'
            vault operator init
            vault operator unseal && vault operator unseal && vault operator unseal
            read -p 'Token (will be hidden): ' -s INITIAL_ROOT_TOKEN
            export VAULT_TOKEN=$INITIAL_ROOT_TOKEN
            vault status
            echo 'URL: http://localhost:8200/ui'

            break
            ;;

        "Start server")
            mkdir -p $HOME/vault/data
            vault server -config=./scripts/vault/config.hcl

            break
            ;;

        "Unseal")
            export VAULT_ADDR='http://127.0.0.1:8200'
            vault operator unseal && vault operator unseal && vault operator unseal
            read -p 'Token (will be hidden): ' -s INITIAL_ROOT_TOKEN
            export VAULT_TOKEN=$INITIAL_ROOT_TOKEN
            vault status
            echo 'URL: http://localhost:8200/ui'

            break
            ;;

        "Seal")
            export VAULT_ADDR='http://127.0.0.1:8200'
            vault login
            vault operator seal
            vault status

            break
            ;;

        "Clean up")
            #ps aux | grep "vault server" | grep -v grep | awk '{print $2}' | xargs kill
            rm -r $HOME/vault

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
