#! /bin/bash

echo "#VAULT_STARTED#" > /data/status

# Start vault
vault server -config=/config/common/vault-server.hcl -non-interactive=true &
SERVER_PID=$(echo $!)

sleep 5

# Export values
export VAULT_ADDR='http://127.0.0.1:8201'
export VAULT_SKIP_VERIFY='true'

# Init vault if necessary
isFirstInitialization=$(vault status | grep "Initialized.*false")

if [ ! -z "$isFirstInitialization" ]; then
   vault operator init >> /data/generated_keys.txt
fi

# Parse unsealed keys and unseal vault
grep "Unseal Key " < /data/generated_keys.txt  | cut -c15- | \
while read -r line ; do
   vault operator unseal ${line}
done

# Get root token
rootToken=$(grep "Initial Root Token: " < /data/generated_keys.txt  | cut -c21- )
export VAULT_TOKEN=${rootToken}


if [ ! -z "$isFirstInitialization" ]; then
  # Enable engines
  vault secrets enable -version=2 -path=secret/ kv
  vault policy write myc-service-policy /config/common/myc-service-policy.hcl

  # Enable approle and add myc service role
  vault auth enable approle
  vault write auth/approle/role/myc-service \
      token_ttl=1h \
      token_max_ttl=4h \
      token_policies=myc-service-policy

  vault write auth/approle/role/myc-service role_id=${MYC_SERVICE_VAULT_ROLE_ID}
  vault write auth/approle/role/myc-service/custom-secret-id secret_id=${MYC_SERVICE_VAULT_SECRET_ID}

fi

# Add secrets
export FIRST_INITIALIZATION=$isFirstInitialization
sh /config/common/add-secrets.sh

echo "#VAULT_CONFIGURED#" > /data/status

wait $SERVER_PID
