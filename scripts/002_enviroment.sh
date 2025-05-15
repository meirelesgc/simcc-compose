#!/bin/bash

declare -A env_vars
declare -A default_vars

env_vars["simcc-admin"]="ADM_DATABASE ADM_USER ADM_HOST ADM_PASSWORD ADM_PORT"
env_vars["simcc-back"]="DATABASE PG_USER PASSWORD HOST PORT ADMIN_DATABASE ADMIN_PG_USER ADMIN_PASSWORD ADMIN_HOST ADMIN_PORT ROOT_PATH PROXY_URL ALTERNATIVE_CNPQ_SERVICE FIREBASE_COLLECTION JADE_EXTRATOR_FOLTER"
env_vars["simcc-back-old"]="DATABASE_NAME DATABASE_USER DATABASE_PASSWORD DATABASE_HOST ADM_DATABASE PORT OPENAI_API_KEY ALTERNATIVE_CNPQ_SERVICE JADE_EXTRATOR_FOLTER"
env_vars["simcc-front"]="VITE_API_KEY VITE_URL_GERAL VITE_URL_GERAL_ADM VITE_REFRESH_TOKEN VITE_CLIENT_ID VITE_VERSION VITE_EXTERNAL_INSTITUTION_ID VITE_SIMCC VITE_PUBLIC_MAPBOX_TOKEN VITE_GA4_PROPERTY_ID VITE_GOOGLE_APPLICATION_CREDENTIALS VITE_APIKEY VITE_AUTHDOMAIN VITE_PROJECTID VITE_STORAGEBUCKET VITE_MESSAGINGSENDERID VITE_APPID VITE_MEASUREMENTID VITE_URL_SITE VITE_BANCO_FIREBASE_SEARCH"

default_vars["simcc-admin"]="simcc_admin postgres simcc-postgres postgres 5432"
default_vars["simcc-back"]="simcc postgres postgres simcc-postgres 5432 simcc_admin postgres postgres simcc-postgres 5432 / http://simcc-back-old:8080/ True search_terms /"
default_vars["simcc-back-old"]="simcc postgres postgres simcc-postgres simcc_admin 5432 ... True /"
default_vars["simcc-front"]="... http://localhost:8000/ http://localhost:9090/ ... ... false ... true ... ... ../cert.json ... ... ... ... ... ... ... localhost search_terms"


read -p "Do you want to fill in the .env files manually? (y/n): " answer

dirs=($(find . -maxdepth 1 -type d -name "simcc-*" -printf "%P\n"))

for dir in "${dirs[@]}"; do
    env_path="$dir/.env"

    echo "Creating $env_path..."

    if [[ -n "${env_vars[$dir]}" ]]; then
        > "$env_path"
        IFS=' ' read -r -a vars <<< "${env_vars[$dir]}"
        IFS=' ' read -r -a defaults <<< "${default_vars[$dir]}"

        for i in "${!vars[@]}"; do
            var="${vars[$i]}"
            if [[ "$answer" == "y" ]]; then
                read -p "Enter value for $var: " value
                echo "$var=$value" >> "$env_path"
            else
                echo "$var=${defaults[$i]}" >> "$env_path"
            fi
        done

        echo "$env_path has been created."
    else
        echo "No variables configured for $dir. Skipping..."
    fi
done
