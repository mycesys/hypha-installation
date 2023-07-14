#!/bin/bash
# This script perform update docker environments for Hypha
# from version 2023.1 to version 2023.2-beta
# You must use docker-compose.yml file for 2023.2-beta version

set -e

if [ "$1" == "--help"  ] || [ "$1" == "-h"  ] ; then
        echo "Specify path to env file. Example: $0 .env"
        echo "Or .env file willbe used by default"
        exit 0
    elif [ -n "$1" ] ; then
        oldenvfile=$1
        echo "Use $1 as env file"
    elif  [ -f ./.env ]; then
        echo "File .env is found. Use it for upgrade"
        oldenvfile=./.env
    else
    echo "Specify path to env file. Example: $0 .env"
    exit 1
fi

newenvfile=.env

#Prepare new folders

./prepare-dirs.sh

#Prepare new env file

cp "$oldenvfile" "$oldenvfile".2023.1-"$(date '+%Y-%m-%d')".backup
echo "$oldenvfile".2023.1-"$(date '+%Y-%m-%d')".backup was created
sed -e '/^\s*#/d' -e '/^$/d' "$oldenvfile" > oldenvfileFoakeim5

dotenv() {
    local REPLY
    while read -r; do
        REPLY=$(printf %s\\n "${REPLY}" | xargs)
        [[ -n $REPLY ]] && export "$REPLY"
    done < <(envsubst)
}
set -a
dotenv < oldenvfileFoakeim5
set +a
rm oldenvfileFoakeim5
{
echo "# This file is generated by script. Check it before usage"
echo "HUB_PUBLIC_URL=$HUB_PUBLIC_URL"
echo "HUB_PUBLIC_PORT=$HUB_PUBLIC_PORT"
echo "HYPHA_PUBLIC_URL=$HYPHA_PUBLIC_URL"
echo "HYPHA_PUBLIC_PORT=$HYPHA_PUBLIC_PORT"

printf '\n'
echo "OAUTH_ISSUER_URL=https://${HUB_PUBLIC_URL}:${HUB_PUBLIC_PORT}"
echo "FRONTEND_BASE_URL=https://${HUB_PUBLIC_URL}:${HUB_PUBLIC_PORT}"
echo "HUB_WEB_APP_BASE_URL=https://${HUB_PUBLIC_URL}:${HUB_PUBLIC_PORT}"
echo "HYPHA_WEB_APP_BASE_URL=https://${HYPHA_PUBLIC_URL}:${HYPHA_PUBLIC_PORT}"
printf '\n'
echo "PROFILE=dev"
echo "CONSUL_HOST=consul"
echo "CONSUL_PORT=8500"
echo "VAULT_URI=http://vault:8201"
echo "RABBITMQ_HOST=$RABBITMQ_HOST"
echo "RABBITMQ_PORT=$RABBITMQ_PORT"
printf '\n'
echo "HYPHA_CORE_VERSION=2023.2-beta"
echo "HYPHA_FILES_VERSION=2023.2-beta"
echo "HYPHA_GATEWAY_VERSION=2023.2-beta"
echo "HYPHA_BFF_VERSION=2023.2-beta"
echo "HYPHA_WORKFLOW_VERSION=2023.2-beta"
echo "HYPHA_RESOURCES_VERSION=2023.2-beta"
echo "HYPHA_TASKS_VERSION=2023.2-beta"
echo "HYPHA_DASHBOARD_VERSION=2023.2-beta"
echo "HYPHA_UI_VERSION=2023.2-beta"
echo "HUB_AUTH_VERSION=2023.2-beta"
echo "HUB_UI_VERSION=2023.2-beta"
printf '\n'
echo "HUB_AUTH_MAIL_SERVER_HOST=$HUB_AUTH_MAIL_SERVER_HOST"
echo "HUB_AUTH_MAIL_SERVER_POST=$HUB_AUTH_MAIL_SERVER_POST"
echo "HUB_AUTH_MAIL_PROTOCOL=$HUB_AUTH_MAIL_PROTOCOL"
echo "HUB_AUTH_MAIL_SMTP_AUTH=$HUB_AUTH_MAIL_SMTP_AUTH"
echo "HUB_AUTH_MAIL_SMTP_AUTH=$HUB_AUTH_MAIL_SMTP_AUTH"
echo "HUB_AUTH_MAIL_TLS_ENABLE=$HUB_AUTH_MAIL_TLS_ENABLE"
echo "HUB_AUTH_MAIL_SSL_ENABLE=$HUB_AUTH_MAIL_SSL_ENABLE"
echo "HUB_AUTH_MAIL_FROM=$HUB_AUTH_MAIL_FROM"
printf '\n'
echo "HUB_AUTH_LIMIT_MAX_RAM=1024m"
echo "HYPHA_BFF_LIMIT_MAX_RAM=2048m"
echo "HYPHA_CORE_LIMIT_MAX_RAM=1024m"
echo "HYPHA_WORKFLOW_LIMIT_MAX_RAM=1024m"
echo "HYPHA_TASK_MANAGER_LIMIT_MAX_RAM=1024m"
echo "HYPHA_RESOURCE_MANAGER_LIMIT_MAX_RAM=2048m"
echo "HYPHA_FILES_MANAGER_LIMIT_MAX_RAM=2048m"
echo "HYPHA_DASHBOARD_LIMIT_MAX_RAM=1024m"
echo "HYPHA_APP_GW_LIMIT_MAX_RAM=1024m"
printf '\n'
echo "HYPHA_RESOURCE_MANAGER_CLUSTER_REFRESH_PERIOD_MS=60000"
printf '\n'
echo "MALLOC_ARENA_MAX=4"
printf '\n'
echo "# SECRETS"
printf '\n'
echo "# required at any start"
echo "MYC_SERVICE_VAULT_ROLE_ID=45e35ef8-ef21-4787-966b-9d1b7eef3c96"
echo "MYC_SERVICE_VAULT_SECRET_ID=ef50b853-886b-481b-9699-22799c607197"
printf '\n'
echo "# required only at first start"
printf '\n'
echo "RABBITMQ_DEFAULT_USER=$RABBITMQ_DEFAULT_USER"
echo "RABBITMQ_DEFAULT_PASS=$RABBITMQ_DEFAULT_PASS"
echo "RABBITMQ_USERNAME=$RABBITMQ_DEFAULT_USER"
echo "RABBITMQ_PASSWORD=$RABBITMQ_DEFAULT_PASS"
printf '\n'
echo "HUB_AUTH_SECRET=$AUTH_SECRET"
echo "HUB_ADMIN_PASSWORD=$ADMIN_PASSWORD"
printf '\n'
echo "HUB_AUTH_MAIL_USERNAME=$HUB_AUTH_MAIL_USERNAME"
echo "HUB_AUTH_MAIL_PASSWORD=$HUB_AUTH_MAIL_PASSWORD"
printf '\n'
echo "HUB_AUTH_DB_USERNAME=$HUB_AUTH_DB_USERNAME"
echo "HUB_AUTH_DB_PASSWORD=$HUB_AUTH_DB_PASSWORD"
printf '\n'
echo "HUB_AUTH_NOTIFICATION_CIPHER_KEY=secretsecretsecr"
printf '\n'
echo "HYPHA_SECRET=$HYPHA_SECRET"
echo "HYPHA_COMMON_CIPHER_KEY=secretsecretsecr"
echo "HYPHA_BFF_DB_USERNAME=$HYPHA_BFF_DB_USERNAME"
echo "HYPHA_BFF_DB_PASSWORD=$HYPHA_BFF_DB_PASSWORD"
echo "HYPHA_CORE_DB_USERNAME=$HYPHA_CORE_DB_USERNAME"
echo "HYPHA_CORE_DB_PASSWORD=$HYPHA_CORE_DB_PASSWORD"
echo "HYPHA_WORKFLOW_DB_USERNAME=$HYPHA_WORKFLOW_DB_USERNAME"
echo "HYPHA_WORKFLOW_DB_PASSWORD=$HYPHA_WORKFLOW_DB_PASSWORD"
echo "HYPHA_TASK_MANAGER_DB_USERNAME=$HYPHA_TASK_MANAGER_DB_USERNAME"
echo "HYPHA_TASK_MANAGER_DB_PASSWORD=$HYPHA_TASK_MANAGER_DB_PASSWORD"
echo "HYPHA_RESOURCE_MANAGER_DB_USERNAME=$HYPHA_RESOURCE_MANAGER_DB_USERNAME"
echo "HYPHA_RESOURCE_MANAGER_DB_PASSWORD=$HYPHA_RESOURCE_MANAGER_DB_PASSWORD"
echo "HYPHA_FILES_MANAGER_DB_USERNAME=$HYPHA_FILES_MANAGER_DB_USERNAME"
echo "HYPHA_FILES_MANAGER_DB_PASSWORD=$HYPHA_FILES_MANAGER_DB_PASSWORD"
echo "HYPHA_DASHBOARD_DB_USERNAME=$HYPHA_DASHBOARD_DB_USERNAME"
echo "HYPHA_DASHBOARD_DB_PASSWORD=$HYPHA_DASHBOARD_DB_PASSWORD"
printf '\n'
} > ${newenvfile}

# Check environments

list_of_envs='HUB_PUBLIC_URL
HUB_PUBLIC_PORT
HYPHA_PUBLIC_URL
OAUTH_ISSUER_URL
FRONTEND_BASE_URL
HYPHA_WEB_APP_BASE_URL
HUB_WEB_APP_BASE_URL
PROFILE
CONSUL_HOST
CONSUL_PORT
VAULT_URI
RABBITMQ_HOST
RABBITMQ_PORT
HYPHA_CORE_VERSION
HYPHA_FILES_VERSION
HYPHA_GATEWAY_VERSION
HUB_AUTH_VERSION
HYPHA_BFF_VERSION
HYPHA_WORKFLOW_VERSION
HYPHA_RESOURCES_VERSION
HYPHA_TASKS_VERSION
HYPHA_DASHBOARD_VERSION
HYPHA_UI_VERSION
HUB_UI_VERSION
HUB_AUTH_MAIL_SERVER_HOST
HUB_AUTH_MAIL_SERVER_POST
HUB_AUTH_MAIL_PROTOCOL
HUB_AUTH_MAIL_SMTP_AUTH
HUB_AUTH_MAIL_TLS_ENABLE
HUB_AUTH_MAIL_SSL_ENABLE
HUB_AUTH_MAIL_FROM
HUB_AUTH_LIMIT_MAX_RAM
HYPHA_BFF_LIMIT_MAX_RAM
HYPHA_CORE_LIMIT_MAX_RAM
HYPHA_WORKFLOW_LIMIT_MAX_RAM
HYPHA_TASK_MANAGER_LIMIT_MAX_RAM
HYPHA_RESOURCE_MANAGER_LIMIT_MAX_RAM
HYPHA_FILES_MANAGER_LIMIT_MAX_RAM
HYPHA_DASHBOARD_LIMIT_MAX_RAM
HYPHA_APP_GW_LIMIT_MAX_RAM
HYPHA_RESOURCE_MANAGER_CLUSTER_REFRESH_PERIOD_MS
MALLOC_ARENA_MAX
MYC_SERVICE_VAULT_ROLE_ID
MYC_SERVICE_VAULT_SECRET_ID
RABBITMQ_USERNAME
RABBITMQ_PASSWORD
HUB_AUTH_SECRET
HUB_ADMIN_PASSWORD
HUB_AUTH_MAIL_USERNAME
HUB_AUTH_MAIL_PASSWORD
HUB_AUTH_DB_USERNAME
HUB_AUTH_DB_PASSWORD
HUB_AUTH_NOTIFICATION_CIPHER_KEY
HYPHA_SECRET
HYPHA_COMMON_CIPHER_KEY
HYPHA_BFF_DB_USERNAME
HYPHA_BFF_DB_PASSWORD
HYPHA_CORE_DB_USERNAME
HYPHA_CORE_DB_PASSWORD
HYPHA_WORKFLOW_DB_USERNAME
HYPHA_WORKFLOW_DB_PASSWORD
HYPHA_TASK_MANAGER_DB_USERNAME
HYPHA_TASK_MANAGER_DB_PASSWORD
HYPHA_RESOURCE_MANAGER_DB_USERNAME
HYPHA_RESOURCE_MANAGER_DB_PASSWORD
HYPHA_FILES_MANAGER_DB_USERNAME
HYPHA_FILES_MANAGER_DB_PASSWORD
HYPHA_DASHBOARD_DB_USERNAME
HYPHA_DASHBOARD_DB_PASSWORD'

#cp .env oldenvfileFoakeim5
#sed -e '/^\s*#/d' -e '/^$/d' ".env" > oldenvfileFoakeim5
source .env

for i in $list_of_envs ; do
    if [[ -z "${!i}" ]]; then
        echo "Warning - the $i environment variable isn't set"
    fi
done

echo "Done."
echo "Env file saved as ${newenvfile}. Please check it."
exit 0