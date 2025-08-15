#!/bin/bash
# This script perform update docker environments for Hypha
# from version 2025.1 to version 2025.2

set -e

# Default URL of the installation script on GitHub
GITHUB_URL="https://github.com/mycesys/hypha-installation/archive/refs/heads/2025.2.zip"

NEW_VERSION_SOURCES=2025.2_"$(date '+%s')"

# The filename to save the downloaded zip file as
ZIP_FILENAME=$NEW_VERSION_SOURCES.zip

# Directory where the unzipped contents will be placed
UNZIP_DIR=$NEW_VERSION_SOURCES

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "This script migrates from version 2025.1 to 2025.2."
  echo "It downloads the new version of the installation script from [GitHub](https://github.com/mycesys/hypha-installation),"
  echo "unzips it, and proceeds with the migration."
  echo
  echo "Options:"
  echo "  -h, --help                 Display this help message and exit."
  echo "  --archive=path/to/archive  Path to the local archive contains 2025.2 installation scripts."
  echo "  --env=path/to/.env         Path to the existing .env configuration file."
  echo
  echo "If there is no connection to GitHub, the script can accept the archive as a named parameter."
  echo "If the path to the local archive is provided, it will be used instead of downloading from GitHub."
  echo
  echo "Examples:"
  echo "  $0                                               # Downloads from GitHub and proceeds with migration"
  echo "  $0 --archive=2025.2.zip                     # Uses provided zip file for migration"
  echo "  $0 --env=config/.env                             # Specifies path to .env file"
  echo "  $0 --archive=2025.2.zip --env=config/.env   # Specifies path to .env file"
}

# Default paths
archive=""
env_file=".env"

# Parse command line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    --archive=*)
      archive="${1#*=}"
      shift
      ;;
    --env=*)
      env_file="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      show_help
      exit 1
      ;;
  esac
done

# Check is environment file exists
if [ -f "$env_file" ]; then
    echo "$env_file will be used as source of previous installation parameters"
else
    echo "Could not find environment file by path $env_file"
    exit 1
fi

# Download from GitHub if no local archive provided
if [ -z "$archive" ]; then
  if curl --output /dev/null --silent --head --fail "$GITHUB_URL"; then
    echo "Downloading from GitHub..."
    archive=$ZIP_FILENAME
    curl -L "$GITHUB_URL" -o "$archive"
  else
    echo "Failed to connect to GitHub, and no local archive provided."
    exit 1
  fi
fi

# Unzip the archive
echo "Unzipping the archive..."
unzip -q "$archive" -d "$UNZIP_DIR"

# Run migration (customize this section as needed)
echo "Running migration..."

# Proceed with migration

#### Copy new version of required files from new installation scripts

for i in 3d-service hub-auth hub-ui hypha-backend-dictionary hypha-bff hypha-core hypha-dashboard hypha-files hypha-gateway hypha-resources hypha-tasks hypha-ui hypha-workflow rabbitmq consul vault; do
  \cp -rf "$UNZIP_DIR"/hypha-installation-2025.2/$i/. ../$i
done

cp "$UNZIP_DIR"/hypha-installation-2025.2/allinone/prepare-dirs.sh ./
cp "$UNZIP_DIR"/hypha-installation-2025.2/allinone/docker-compose.yml ./
cp "$UNZIP_DIR"/hypha-installation-2025.2/allinone/licenses/support.default ./licenses/support.default
cp -r "$UNZIP_DIR"/hypha-installation-2025.2/allinone/vault_config ./


#### Creating a backup for existing .env file

backupenvfile="$env_file".2025.1-"$(date '+%s')".backup
cp "$env_file" "$backupenvfile"
echo "Backup environment file: $backupenvfile successfully created"

#### Prepare new folders

./prepare-dirs.sh

#### Prepare new environment file

{
  echo "STL_SERVICE_BASE_URL=http://3d-service:8080/rest/v1/models"
  echo "HYPHA_WEB_APP_BRANDING_TITLE=Hypha"
  echo "HYPHA_WEB_APP_BRANDING_PREFIX=hypha"
  echo "HUB_WEB_APP_BRANDING_TITLE=Hub"
  echo "GLOBAL_WEB_APP_BRANDING_TITLE=Mycesys"
  echo "USERGUIDE_URL=https://mycesys.com/hypha/latest/userguide.pdf"
  echo "DEFAULT_SYSTEM_LANGUAGE=en"
  echo "HYPHA_BACKEND_DICTIONARY_VERSION=2025.2.19"

} >> ${env_file}

sed -i s/PROFILE\=dev/PROFILE\=prod/ ${env_file}

# Use new nersions
source dot.env.example

sed -i s/HYPHA_CORE_VERSION=.*/HYPHA_CORE_VERSION="$HYPHA_CORE_VERSION"/ ${env_file}
sed -i s/HYPHA_FILES_VERSION=.*/HYPHA_FILES_VERSION="$HYPHA_FILES_VERSION"/ ${env_file}
sed -i s/HYPHA_GATEWAY_VERSION=.*/HYPHA_GATEWAY_VERSION="$HYPHA_GATEWAY_VERSION"/ ${env_file}
sed -i s/HYPHA_BFF_VERSION=.*/HYPHA_BFF_VERSION="$HYPHA_BFF_VERSION"/ ${env_file}
sed -i s/HYPHA_WORKFLOW_VERSION=.*/HYPHA_WORKFLOW_VERSION="$HYPHA_WORKFLOW_VERSION"/ ${env_file}
sed -i s/HYPHA_RESOURCES_VERSION=.*/HYPHA_RESOURCES_VERSION="$HYPHA_RESOURCES_VERSION"/ ${env_file}
sed -i s/HYPHA_TASKS_VERSION=.*/HYPHA_TASKS_VERSION="$HYPHA_TASKS_VERSION/" ${env_file}
sed -i s/HYPHA_DASHBOARD_VERSION=.*/HYPHA_DASHBOARD_VERSION="$HYPHA_DASHBOARD_VERSION/" ${env_file}
sed -i s/HYPHA_UI_VERSION=.*/HYPHA_UI_VERSION="$HYPHA_UI_VERSION/" ${env_file}
sed -i s/HUB_AUTH_VERSION=.*/HYPHA_UI_VERSION="$HYPHA_UI_VERSION/" ${env_file}
sed -i s/HUB_UI_VERSION=.*/HUB_UI_VERSION="$HUB_UI_VERSION"/ ${env_file}
sed -i s/HYPHA_BACKEND_DICTIONARY_VERSION=.*/HYPHA_BACKEND_DICTIONARY_VERSION="$HYPHA_BACKEND_DICTIONARY_VERSION/" ${env_file}

echo "Migration completed. Checking generated environment file..."

#### Check environments

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
HYPHA_BACKEND_DICTIONARY_VERSION
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
HYPHA_DASHBOARD_DB_PASSWORD
DISCOVERY_PREFER_IP
DISCOVERY_IP_ADDRESS
STL_SERVICE_BASE_URL
HYPHA_3D_SERVICE_DB_USERNAME
HYPHA_3D_SERVICE_DB_PASSWORD
HYPHA_3D_FREECAD_SERVICE_URL
HYPHA_3D_SERVICE_POSTGRES_URL
HYPHA_3D_SERVICE_SPRING_MAX_FILE_SIZE
HYPHA_3D_SERVICE_SPRING_MAX_REQUEST_SIZE
HYPHA_WEB_APP_BRANDING_TITLE
HYPHA_WEB_APP_BRANDING_PREFIX
HUB_WEB_APP_BRANDING_TITLE
GLOBAL_WEB_APP_BRANDING_TITLE
USERGUIDE_URL
DEFAULT_SYSTEM_LANGUAGE'

source $env_file

for key in $list_of_envs ; do
    if [[ -z "${!key}" ]]; then
        echo "WARNING: the $key environment variable isn't set"
    fi

    if [ "$key" == "HYPHA_COMMON_CIPHER_KEY" ] || [ "$key" == "HUB_AUTH_NOTIFICATION_CIPHER_KEY" ]; then
      value=${!key}
      if [ "${#value}" != 16 ] && [ "${#value}" != 24 ] && [ "${#value}" != 32 ]; then
        echo "ERROR: $key value should be 16, 24 or 32 symbols length, but lengh is ${#value}"
      fi
    fi
done

echo "Please check updated environment file before start. File location: $env_file"
exit 0
