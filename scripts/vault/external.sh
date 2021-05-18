#!/bin/bash

PS3="Please select your choice: "
options=(
    "Login" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Login")
            read -p 'VAULT_ADDR: ' vault_addr
            export VAULT_ADDR=$vault_addr
            read -p 'role_id (will be hidden): ' -s role_id && echo ''
            read -p 'secret_id (will be hidden): ' -s secret_id && echo ''
            VAULT_TOKEN=$(curl --request POST --data "{\"role_id\": \"$role_id\", \"secret_id\": \"$secret_id\"}" $VAULT_ADDR/v1/auth/approle/login | jq -r ".auth.client_token")
            vault login $VAULT_TOKEN

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
