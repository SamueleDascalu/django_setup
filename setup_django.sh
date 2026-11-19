#!/usr/bin/env bash
set -euo pipefail

ask_folder_name() {
    local name
    read -rp "Enter a name for the root folder of the project: " name
    echo "$name"
}

printf '####################################\n'
printf '####  Setup for Django projects ####\n'
printf '####################################\n\n'

printf 'Entering ~/Desktop ...\n\n'
cd ~/Desktop

folder_name=$(ask_folder_name)
while [[ -z "$folder_name" || "$folder_name" == */* || -e "./$folder_name" ]]; do
    if [[ "$folder_name" == */* ]]; then
        printf '\nThe name cannot contain "/".\n'
    elif [[ -n "$folder_name" ]]; then
        printf '\n"%s" already exists. Current contents:\n' "$folder_name"
        ls
    fi
    printf '\nRetry ...\n'
    folder_name=$(ask_folder_name)
done

mkdir "$folder_name"
printf '\nEntering %s/ ...\n' "$folder_name"
cd "./$folder_name"

printf '\nCreating a virtual environment named .venv ...\n'
python3 -m venv .venv

VENV_PY=".venv/bin/python"

printf '\nUpgrading pip ...\n\n'
$VENV_PY -m pip install --upgrade pip

while true; do
    read -rp $'\nInstall the latest version of Django? (Y/n): ' option
    case "${option:-Y}" in
        [Yy])
            printf "\n"
            $VENV_PY -m pip install django && break
            ;;
        [Nn])
            while true; do
                read -rp $'\nInsert the version of Django to install: ' version
                [[ $version =~ ^[0-9]+(\.[0-9]+){0,2}$ ]] && break
                printf '\nInvalid version: %s. Try again.\n' "$version" >&2
            done
            case $version in
                *.*.*) spec="django==$version" ;;
                *.*)   spec="django~=$version.0" ;;
                *)     spec="django~=$version.0" ;;
            esac
            printf "\n"
            $VENV_PY -m pip install "$spec" && break
            ;;
        *)
            echo $'\nPlease answer Y or n.\n' >&2
            ;;
    esac
done

printf '\nDjango %s is now installed.\n' $(django-admin --version)

printf "\nCreating the Django project ...\n"

$VENV_PY -m django startproject config .

mkdir apps/

printf '\nActivating the virtual environment ...\n'

source .venv/bin/activate

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    echo "Error: virtual environment was not activated." >&2
    exit 1
fi
echo $'\nVirtual environment is now active.'