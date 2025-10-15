#!/bin/bash

PASSPHRASE=mycesys_ssl_pass

# Add SSL key to hub-auth applicatiom
docker exec -i hub-auth bash -c "cd /ssl; keytool -importkeystore -srckeystore ./identity.p12 -srcstoretype PKCS12 -srcstorepass $PASSPHRASE -destkeystore /opt/java/openjdk/lib/security/cacerts -deststoretype JKS -deststorepass changeit"

# Add SSL key to hypha-gateway application
docker exec -i hypha-gateway bash -c "cd /ssl; keytool -importkeystore -srckeystore ./identity.p12 -srcstoretype PKCS12 -srcstorepass $PASSPHRASE -destkeystore /opt/java/openjdk/lib/security/cacerts -deststoretype JKS -deststorepass changeit"

docker restart hub-auth hypha-gateway
