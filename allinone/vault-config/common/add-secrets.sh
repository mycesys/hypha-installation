#! /bin/bash

ls /config/product | grep ".*" | \
while read -r productName ; do

   ls /config/product/$productName | grep ".*" | \
   while read -r serviceName ; do
     echo $FIRST_INITIALIZATION
      if [ ! -z "$FIRST_INITIALIZATION" ]; then
        vault kv put secret/$serviceName key=value
      fi

      cat /config/product/$productName/$serviceName  | \
      while read -r kvString ; do
        if [ ! -z "$kvString" ]; then
          resovledKv=$(eval echo -E "$kvString")

          nonblankValueTest=$(eval echo $resovledKv | grep ".*=[\s]*$")
          if [ -z "$nonblankValueTest" ]; then
#            echo secret/$serviceName $resovledKv
            key=$(echo $resovledKv | sed -E  's/([^=]*)=(.*)/\1/')
            value=$(echo $resovledKv | sed -E  's/([^=]*)=(.*)/\2/')

            existingValue=$(vault kv get -field=$key secret/$serviceName)

            if [ "$value" != "$existingValue" ]; then
              vault kv patch secret/$serviceName $resovledKv
            fi
          fi
        fi
      done

   done

done


