#!/bin/bash

PS3="Please select your choice: "
options=(
    "Install" \
    "Install GUIs" \
    "Local PostgreSQL, setting password for the postgres user" \
    "PostgreSQL shell" \
    "PostGis, enable features on a database" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Install")
            sudo apt-get install -y postgresql postgresql-contrib
            sudo apt-get install -y postgis

            break
            ;;

        "Install GUIs")
            #sudo snap install dbeaver-ce
            wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
            echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
            sudo apt-get update
            sudo apt-get install -y dbeaver-ce

            break
            ;;

        "Local PostgreSQL, setting password for the postgres user")
            read -p 'PGPASSWORD [postgres]: ' -s pgpassword && echo ''
            if [ -z "$pgpassword" ]; then
                pgpassword='postgres'
            fi
            echo "ALTER USER postgres PASSWORD '$pgpassword';" | sudo -u postgres psql postgres

            break
            ;;

        "PostgreSQL shell")
            read -p 'Host (will be hidden) [localhost]: ' -s host && echo ''
            if [ -z "$host" ]; then
                host='localhost'
            fi
            read -p 'User (will be hidden) [postgres]: ' -s user && echo ''
            if [ -z "$user" ]; then
                user='postgres'
            fi
            read -p 'PGPASSWORD (will be hidden) [postgres]: ' -s pgpassword && echo ''
            if [ -z "$pgpassword" ]; then
                pgpassword='postgres'
            fi
            read -p 'Database: ' database

            export PGPASSWORD=$pgpassword
            psql -h $host -p 5432 -U $user -d $database

            break
            ;;

        "PostGis, enable features on a database")
            read -p 'Host (will be hidden) [localhost]: ' -s host && echo ''
            if [ -z "$host" ]; then
                host='localhost'
            fi
            read -p 'User (will be hidden) [postgres]: ' -s user && echo ''
            if [ -z "$user" ]; then
                user='postgres'
            fi
            read -p 'PGPASSWORD (will be hidden) [postgres]: ' -s pgpassword && echo ''
            if [ -z "$pgpassword" ]; then
                pgpassword='postgres'
            fi
            read -p 'Database: ' database

            export PGPASSWORD=$pgpassword
            cmd='create extension postgis; create extension fuzzystrmatch; create extension postgis_tiger_geocoder; create extension postgis_topology; select postgis_version();'
            echo $cmd | psql -h $host -p 5432 -U $user -d $database

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
