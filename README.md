## Introduction

- Website: https://mycesys.com
- What is Hypha:

Hypha is a SPDM system that allows to manage data and simulations, run computational tasks and process the results. First enterprise level system available for teams up to 5 users for free.

- User guide: https://mycesys.com/hypha/latest/userguide.pdf
- Installation guide: https://github.com/mycesys/hypha-installation
- Docker images: https://hub.docker.com/u/mycesys

## Installation

### Table of content

1. [Requirements](#1-requrements)
2. [Installation](#2-installation-all-in-one)
 - [Configuration](#configuration)
 - [Run Hypha & Hub](#run-hypha--hub)
 - [First steps](#first-steps)
3. [Advanced guide](#3-advanced-guide)
-  [Generate and use self-signed SSL certificate](#generate-and-use-self-signed-ssl-certificate)
-  [Install Hypha on several nodes](#install-hypha-on-several-nodes)
4. [Technical details](#4-technical-details)
- [Arhcitecture](#architecture)
- [Directories](#list-of-directories)
- [Environment configuration](#environment-configuration)
5. [Troubleshooting](#5-troubleshooting)
6. [Update existing installation](#6-update-existing-installation)
- [2023.1 to 2023.2](#20231-to-20232)
- [2023.2 to 2023.3](#20232-to-20233)
- [2023.4 to 2024.1](#20233-to-20241)
- [2024.1 to 2025.1](#20241-to-20251)
- [2025.1 to 2025.2](#20251-to-20252)
- [2025.2 to 2025.3](#20252-to-20253)


### 1. Requrements

This is a recommended configuration for basic installation. If you need requirements based on your environment and team size please contact us by: [hypha@mycesys.com](mailto:hypha@mycesys.com).

#### Hardware

- Minimal

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| All in one + Hub | 8 | 24 | 512 Gb |

- Optimal

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| All in one | 16 | 64 | 512 Gb |
| Hub | 4 | 6 | 60 Gb |

- Enterprise

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| Hub | 4 | 16 | 60 Gb |
| Core | 8 | 24 | 60 Gb |
| Task manager | 8 | 16 | 60 Gb |
| Resource manager| 8 | 16 | 60 Gb |
| Workflow | 4 | 16 | 60 Gb |
| BFF | 4 | 16 | 60 Gb |
| Dashboard | 4 | 16 | 60 Gb |
| Files | 4 | 24 | 512 Gb |
| Gateway | 4 | 16 | 60 Gb |

#### Software

- `docker` ([Official installation guide](https://docs.docker.com/engine/install/))
- `docker compose` ([Official installation guide](https://docs.docker.com/compose/install/linux/))
- `openssl` (Use your distributive repositories or [official website](https://www.openssl.org/) to install)

#### Host & Network

- Internet access to [Docker Hub](https://hub.docker.com)
- Privileges to run docker containers
- SSL certificate (HTTPS required to support OAuth and native hashing algorithm)
        - If you don't have one you can get it for free from https://letsencrypt.org/ or use self-signed

#### Operating system
- Any operating system that supports docker containers
- Installation scripts are now available only for Unix-like operating systems

### 2. Installation (All in one)

**NOTE:** if you already have an installed version of Hypha please check the [Update section](#6-update-existing-installation) of this guide.

#### Configuration

- Docker images at Docker Hub: https://hub.docker.com/u/mycesys
- Sample configuration & scripts: https://github.com/mycesys/hypha-installation
  - To download current repository content use this command (or clone it with `git`):

```bash
wget https://github.com/mycesys/hypha-installation/archive/refs/heads/main.zip
```

**NEXT STEPS SHOULD BE EXECUTED IN `hypha-installation/allinone` directory**

##### Prepare directories

- Run the following script to create directories:

```bash
./prepare-dirs.sh
```

- Full list of directories could be found in [Technical details / List of directories](#list-of-directories) section.
- **NOTE:** The `files/data` directory is used to store all models and simulation data. Ensure there is enough space available for this purpose.


##### Configure certificates and keys

- OAuth
  - Place the `oauth` (private) and `oauth.pub` (corresponding public) keys in `oauth/keys`. The keys must be generated using the RSA algorithm in PKCS8 format
  - To generate new keys run the script:

```bash
./generate-oauth-keys.sh
```

- SSL
  - Place SSL certificate files into `./ssl` directory

  | File | Description |
  | ------ | ----------------- |
  | `ssl-dhparams.pem` | Diffie-Hellman group |
  | `fullchain.pem` |SSL certificate |
  | `privkey.pem` | SSL private key |
  | `options-ssl-nginx.conf` | SSL configuration file (decribed below) |

  - `options-ssl-nginx.conf` could be found in `selfsigned/` (if you don't have one from SSL certificate provider)
  - To generate self-signed SSL certificate follow the instructions at chapter [3. Advanced guide: generate SSL certificate](#generate-and-use-self-signed-ssl-certificate)

##### Configure `.env` file

- Copy sample environment file to `.env`:

```bash
cp ./dot.env.example ./.env
```

- Required changes in `.env`
  - Redirect URLs

  | Key=Value | Description |
  | ------ | ----------------- |
  | `HUB_PUBLIC_URL=hypha.yourdomain.com` | place here public address (IP or domain name) of hub instance |
  | `HUB_PUBLIC_PORT=8301` | port for Hub interface |
  | `HYPHA_PUBLIC_URL=hypha.yourdomain.com` | place here public address (IP or domain name) of hypha instance |
  | `HYPHA_PUBLIC_PORT=8300` | port for Hypha interface |

  - **NOTE: If you are going to use standard HTTP ports (80 for HTTP and 443 for HTTPS), please set the URLs manually without specifying the port (e.g., ':80' or ':443'), as browsers automatically omit the port in such cases. Parameters described above should be set in any case, sorry for the inconvenience**
  - You should set proper version number for each service. You can check latest versions from [docker hub](https://hub.docker.com/u/mycesys)
  - All other changes in `.env` are optional for all-in-one setup. To learn more follow the guide at: [Technical details / Environment configuration](#environment-configuration)

**For all-in-one installation <HYPHA_PUBLIC_URL> and <HUB_PUBLIC_URL> could be the same but ports should be different.**

#### Run Hypha & Hub

- To start the system run following scripts:

```bash
docker compose pull
```

```bash
docker compose up -d
```

- If you are using a self-signed certificate, do not forget to perform the additional steps described in [3. Advanced guide: addtional configuration steps](#additional-steps)

#### First steps

- Open your browser and follow the link: https://HYPHA_PUBLIC_URL:HYPHA_PUBLIC_PORT
- If you are using a self-signed certificate, you should confirm security exception in browser
- Your should see login form now:
  - Use `admin@mycesys.com` as a login
  - Use `root` as password (if you did not change it in `.env` during the installation process)
- After successful login you will be redirected to Dashboard page
- To learn how to create models, run workflows and more, please take a look at the [user guide](https://mycesys.com/hypha/2023.1/userguide.pdf). If you encounter any errors, check our [Troubleshooting](#5-troubleshooting) section.
- In this version of the system (2023.2) some administration actions could be done only with direct API call. You can find bash scripts for this actions in `scripts` directory in this repository or [download them from site](https://mycesys.com/hypha/2023.1/adm_scripts.tar.gz):
- Extent your license (to obtain a license file please contact us using our website www.mycesys.com)

 ```bash
 scripts/hub-add_license_users.sh
 ```

 ```bash
 scripts/hub-add_license_support.sh
 ```

- Change password settings

 ```bash
 scripts/hub-update_password_format.sh
 ```

- Change confirmation lifetime

```bash
scripts/hub-update_confirmation_lifetime.sh
```

### 3. Advanced guide

#### Generate and use self-signed SSL certificate

You can obtain SSL certificate for your DNS record or IP address and use it to secure network conenctions for free without CA (certificate authority).

**Advantages**
- Free long term SSL certificate
- Easy to manage (creation, changing, prolongation)
- No dependencies on CA

**Disadvantages**
- Browser will ask for confirmation
- Additional steps in installation process required

##### How to obtain the certificate

- All actions should be performed in `allinone` directory
- Copy `selfsigned/v3.ext` and `selfsigned/ssl.cnf` to `ssl/`

```bash
cp selfsigned/ssl.cfg ssl/
```

```bash
cp selfsigned/v3.ext ssl/
```

- Fill `ssl/ssl.cfg` with your server parameters
        - `C = US` - country code
        - `ST = State` - state
        - `L = City` - your city
        - `O = Org LLC` - your organization
        - `OU = Org Unit` - your organization unit
        - `CN = example.com` - Common Name: set your server FQDN or IP address here
- Fill `ssl/v3.ext` with your server parameters
  - `subjectAltName = IP:value,DNS:value` - place comma separated pairs `IP:<ip address>` or `DNS:<DNS name>` corresponding to your server
- Run the following script to generate keys (might take some time):

```bash
./generate-ssl-keys.sh
```
- Now you have self signed certificate for 10 years with SAN block. [Return to configuration](#configure-env-file)

##### Additional steps

**After running all containers add SSL certificate to `hub-auth` and `hypha-gateway` JKS keystores**

- Run the following script:
```bash
./add-ssl-keys-to-jdk.sh
```
- **NOTE:** If you did not use the `generate-ssl-keys.sh` script to create SSL certificates, be sure to set the correct passphrase for the private key in the `PASSPHRASE` variable within the `add-ssl-keys-to-jdk.sh` script.


#### Install Hypha on several nodes

- You can spread system components on nodes
- To do it you can use docker composes from `hypha-installation` to install each component separately
- In this case ensure that you properly set services URLs in each `.env` file (in the next version of Hypha this will be not neccessary)
- We recommend to start with separating `Hub` components because `Hub` is completely independent service

### 4. Technical details

####  Architecture

![All in one installation scheme](https://mycesys.com/hypha/2023.1/hypha-hub_allinone_scheme.png)

#### List of directories

| Path                   | Description                                                                                                            |
|------------------------|------------------------------------------------------------------------------------------------------------------------|
| `auth/user/avatars/`   | place where avatars for all users are stored                                                                           |
| `core/common/avatars/` | place where avatars for all other objects are stored                                                                   |
| `files/data/`          | place where all main data is stored (models, simulation results etc). Usually these files take a large amount of space |
| `oauth/keys/`          | place for RSA keys used in OAuth2 authentication process                                                               |
| `ssh/keys/`            | place for SSH-keys for all computational clusters                                                                      |
| `ssl/`                 | place for SSL certificates for HTTPS support                                                                           |
| `pg_auth`              | PostgreSQL data directory for authentication service (Hub)                                                             |
| `pg_core`              | PostgreSQL data directory for core service                                                                             |
| `pg_dashboard`         | PostgreSQL data directory for dashboard service                                                                        |
| `pg_fm`                | PostgreSQL data directory for files management service                                                                 |
| `pg_rm`                | PostgreSQL data directory for resources management service                                                             |
| `pg_tm`                | PostgreSQL data directory for tasks management service                                                                 |
| `pg_workflow`          | PostgreSQL data directory for workflow management service                                                              |
| `rabbitmq_data`        | RabbitMQ directory for persistent data                                                                                 |
| `consul_data`          | HashiCorp Consul directory for persistent data                                                                         |
| `vault_data`           | HashiCorp Vault directory for persistent data                                                                          |

#### Environment configuration

- Secrets

| Key=Value                                                   | Description |
| ----------------------------------------------------------------| ----------------- |
| `HUB_ADMIN_PASSWORD`=root                                   | default password for first user: `admin@mycesys.com` |
| `HUB_AUTH_SECRET`=random_long_string_here                   | strong password (randomly generated) with length no less than 32 characters |
| `HYPHA_SECRET`= random_long_string_here                     | strong password (randomly generated) with length no less than 32 characters |
| `MYC_SERVICE_VAULT_ROLE_ID`= random_long_string_here        | strong password (randomly generated) with length no less than 32 characters |
| `MYC_SERVICE_VAULT_SECRET_ID`= random_long_string_here      | strong password (randomly generated) with length no less than 32 characters |
| `HYPHA_COMMON_CIPHER_KEY`= random_long_string_here          | Used for AES encryption. Should be 32, 24 or 16 symbols lengths |
| `HUB_AUTH_NOTIFICATION_CIPHER_KEY`= random_long_string_here | Used for AES encryption. Should be 32, 24 or 16 symbols length |

- Email Notifications

  | Key=Value | Description                                         |
  |-----------------------------------------------------| ----------------- |
  | `HUB_AUTH_MAIL_SERVER_HOST`=smtp.gmail.com | mail server host                                    |
  | `HUB_AUTH_MAIL_SERVER_POST`=587  | mail server port                                    |
  | `HUB_AUTH_MAIL_USERNAME`=no-reply@mycesys.com | user name (email address) of the mail account       |
  | `HUB_AUTH_MAIL_PASSWORD`=secret | user password (or token) of the mail account        |
  | `HUB_AUTH_MAIL_PROTOCOL`=smtp  | protocol used for emails transferring               |
  | `HUB_AUTH_MAIL_SMTP_AUTH`=true | use mail account authentication                     |
  | `HUB_AUTH_MAIL_TLS_ENABLE`=true | use TLS protocol                                    |
  | `HUB_AUTH_MAIL_SSL_ENABLE`=false  | use SSL protocol                                    |
  | `HUB_AUTH_MAIL_FROM`=no-reply@mycesys.com | email address from which notifications will be sent |


### 5. Troubleshooting

#### Common techniques

- To check all running containers run:

```bash
docker ps
```

- To look at specific container system.output (logs) run:

```bash
docker logs <container_name> | less
```

- To look at nat routing rules in iptables run:

```bash
iptables -t nat -L --line-numbers
```

#### Issues with environment configuration

- Symptom: Endless redirects and reloading when trying to access the login page
  - Check `HYPHA_PUBLIC_URL` and `HUB_PUBLIC_URL` in `.env` file: they should refer to either `localhost` or `127.0.0.1` because each docker container has its own `localhost`
  - Check SSL certificate parameters (described below)

#### Issues with self-signed SSL certificate

- Symptom: some requests ends with 500 status code and  `java.security.cert.CertificateException` appears in the logs
  - Java stacktrace

```java
Caused by: java.security.cert.CertificateException: No subject alternative names present
 at java.base/sun.security.util.HostnameChecker.matchIP(Unknown Source)
 at java.base/sun.security.util.HostnameChecker.match(Unknown Source)
 at java.base/sun.security.ssl.X509TrustManagerImpl.checkIdentity(Unknown Source)
 at java.base/sun.security.ssl.X509TrustManagerImpl.checkIdentity(Unknown Source)
 at java.base/sun.security.ssl.X509TrustManagerImpl.checkTrusted(Unknown Source)
 at java.base/sun.security.ssl.X509TrustManagerImpl.checkServerTrusted(Unknown Source)
```

  - Check your SSL certificate in browser (guide for Chrome browser)
    - click certificate icon in URL field in browser and then click `certificate details`
    - switch to `details` tab
    - Find `Certificate -> Extension -> Certificate Subject Alternative Name`
    - This section should exits
    - DNS names or IPs should refer to your server DNS/IP
- Symptom: HTTP requests with `500` status code, exeptions in logs like:

```
org.springframework.security.oauth2.jwt.JwtDecoderInitializationException: Failed to lazily resolve the supplied JwtDecoder instance
```
  - Ensure that you have added SSL certificates to JDK ([3. Advanced guide: addtional configuration steps](#additional-steps))

#### Issues with routing

- Symptom: `Connection refused` error in logs after login attemp.
  - Environment: often reproduces when system is installed on VM with ports forwading (maybe on router)
  - Check: try to call an API method `https:<HUB_URL>/oauth2/jwks`, it should be accessible from host and from `hub-auth`, `hypha-gateway` docker containers
```bash
curl -k --location --request GET https://<HUB_URL>/oauth2/jwks
```
  - If it fails than you need some routing configuration to make it working fine
  - Here is an example:

![Environment scheme](https://mycesys.com/hypha/2023.1/2023_1_issue_network_routing.png)

  - On this scheme all `Connections` should work properly
  - To allow connections from VM to `Public interface` you should add following rules (iptables):

```bash
iptables -t nat -A POSTROUTING --source yyy.yyy.yyy.yyy  --destination xxx.xxx.xxx.xxx -p tcp --dport 6080 -j SNAT --to-source yyy.yyy.yyy.yyy
iptables -t nat -A POSTROUTING --source yyy.yyy.yyy.yyy  --destination xxx.xxx.xxx.xxx -p tcp --dport 6081 -j SNAT --to-source yyy.yyy.yyy.yyy
```
  - To allow connections from docker containers to `Public interface` you can add following line to `hypha-gateway` and `hub-auth` sections in docker-compose.yml:

```yml
 extra_hosts:
      - "<HYPHA_PUBLIC_DOMAIN>:yyy.yyy.yyy.yyy"
```

### 6. Update existing installation

**Before update:**

- We are strongly recommending to back up:
  - all databases
  - data from 'files/data' directory
  - configuration
- If you made any changes to `docker-compose.yml` in previous installation please ensure that you create a backup.

#### 2023.1 to 2023.2

**Update version**

1. Download `config-migration_2023.1-2-2023.2.sh` script from the [repository](https://github.com/mycesys/hypha-installation/tree/2023.2/allinone/)
2. Run migration script
- Run script `config-migration_2023.1-2-2023.2.sh` in `./allinone` directory

```bash
./config-migration_2023.1-2-2023.2.sh
```

- For more details please run:

```bash
./config-migration_2023.1-2-2023.2.sh --help
```

- Please check new `.env` file generated by script before start
- Please check new `docker-compose.yml` file before start. If you made any changes during the installation of previous version, please sync them with new version of this file.
- Please check new nginx configuration files:
  - `nginx.hub_frontend.conf`
  - `nginx.hypha_frontend.conf`
3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d
```

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2023.2 to 2023.3

**Update version**

1. Download `config-migration_2023.2-2-2023.23.sh` script from the [repository](https://github.com/mycesys/hypha-installation/tree/2023.3/allinone/)
2. Run migration script
- Run script `config-migration_2023.2-2-2023.3.sh` in `./allinone` directory

```bash
./config-migration_2023.2-2-2023.3.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables `DISCOVERY_PREFER_IP` and `DISCOVERY_IP_ADDRESS` are presented 
- Please check new `docker-compose.yml` file before start. If you made any changes during the installation of previous version, please sync them with new version of this file.
- Please use new `ssl_cert.conf` file for SSL/TLS certificates setup.

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2023.3 to 2024.1

**Update version**

1. Download `config-migration_2023.3-2-2024.1.sh` script from the [repository](https://github.com/mycesys/hypha-installation/tree/2024.1/allinone/)
2. Run migration script
- Run script `config-migration_2023.2-2-2023.3.sh` in `./allinone` directory

```bash
./config-migration_2023.3-2-2024.1.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables `DISCOVERY_PREFER_IP` and `DISCOVERY_IP_ADDRESS` are presented 
- Now `docker-compose.yml` is splitted by serices. Please check new `docker-compose.yml` file before start. If you made any changes during the installation of previous version, please sync them with new version of this file.
- Please use new `ssl_cert.conf` file for SSL/TLS certificates setup.

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2024.1 to 2025.1

**Update version**

1. Download `config-migration_2024.1-2025.1.sh` script from the [repository](https://github.com/mycesys/hypha-installation/tree/2025.1/allinone/)
2. Run migration script
- Run script `config-migration_2024.1-2025.1.sh` in `./allinone` directory

```bash
./config-migration_2024.1-2025.1.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables about 3d-service are presented 

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2025.1 to 2025.2

**Update version**

1. Download `config-migration_2025.1-2025.2.sh` script from the [repository](https://github.com/mycesys/hypha-installation/tree/2025.2/allinone/)
2. Run migration script
- Run script `config-migration_2025.1-2025.2.sh` in `./allinone` directory

```bash
./config-migration_2025.1-2025.2.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables about branding and i18n are presented 

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2025.2 to 2025.3

**Update version**

1. Download `config-migration_2025.2-2025.3.sh` script from the [repository](https://github.com/mycesys/hypha-installation/tree/2025.3/allinone/)
2. Run migration script
- Run script `config-migration_2025.2-2025.3.sh` in `./allinone` directory

```bash
./config-migration_2025.2-2025.3.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables about branding and i18n are presented 

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```
