#!/bin/sh
export VAULT_ADDR='http://127.0.0.1:8201'
export VAULT_SKIP_VERIFY='true'
rootToken=$(grep "Initial Root Token: " < /data/generated_keys.txt  | cut -c21- )
export VAULT_TOKEN="${rootToken}"

ls /config/product | grep ".*" | \
while read -r productName ; do

  ls /config/product/"$productName" | grep ".*" | \
    while read -r serviceName ; do
      echo "Processing service: $serviceName"

      # Create tempfile
      temp_file=$(mktemp)

      # Get all KVs
      cat /config/product/"$productName"/"$serviceName" | \
      while read -r kvString ; do
        if [ ! -z "$kvString" ]; then
          resolvedKv=$(eval echo -E "$kvString")
          nonblankValueTest=$(echo "$resolvedKv" | grep ".*=[\s]*$")
          if [ -z "$nonblankValueTest" ]; then
            echo "$resolvedKv" >> "$temp_file"
          fi
        fi
      done

      # Create or update KVs
      if [ -s "$temp_file" ]; then
        # Create if not exist
        if ! vault kv get secret/"$serviceName" > /dev/null 2>&1; then
          echo "Creating new secret for $serviceName"
          # Create first KV for servcice
          first_kv=$(head -1 "$temp_file")
          vault kv put secret/"$serviceName" "$first_kv"

          # Add another KV for service
          tail -n +2 "$temp_file" | \
          while read -r kvString; do
            vault kv patch secret/"$serviceName" "$kvString"
          done
        else
          echo "Updating existing secret for $serviceName"
          cat "$temp_file" | \
          while read -r kvString; do
            key=$(echo "$kvString" | sed -E 's/([^=]*)=(.*)/\1/')
            value=$(echo "$kvString" | sed -E 's/([^=]*)=(.*)/\2/')
            existingValue=$(vault kv get -field="$key" secret/"$serviceName" 2>/dev/null || echo "NOT_EXIST")

            if [ "$value" != "$existingValue" ]; then
              vault kv patch secret/"$serviceName" "$kvString"
            fi
          done
        fi
      fi

      rm -f "$temp_file"
    done
done
