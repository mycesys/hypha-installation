#!/bin/bash

PASSPHRASE=$(cat ssl/ssl_passwords)

# Add SSL key to hub-auth applicatiom
docker exec -i hub-auth bash -c "cd /ssl; keytool -delete -storepass changeit -keystore /opt/java/openjdk/lib/security/cacerts -alias hypha"
docker exec -i hub-auth bash -c "cd /ssl; keytool -importkeystore -srckeystore ./identity.p12 -srcstoretype PKCS12 -srcstorepass $PASSPHRASE -destkeystore /opt/java/openjdk/lib/security/cacerts -deststoretype PKCS12 -deststorepass changeit"

# Add SSL key to hypha-gateway application
docker exec -i hypha-gateway bash -c "cd /ssl; keytool -delete -storepass changeit -keystore /opt/java/openjdk/lib/security/cacerts -alias hypha"
docker exec -i hypha-gateway bash -c "cd /ssl; keytool -importkeystore -srckeystore ./identity.p12 -srcstoretype PKCS12 -srcstorepass $PASSPHRASE -destkeystore /opt/java/openjdk/lib/security/cacerts -deststoretype PKCS12 -deststorepass changeit"

#Create pkcs12 keystore with certificate
openssl pkcs12 -export -passin pass:${PASSPHRASE} -passout pass:${PASSPHRASE} -in ssl/fullchain.pem -inkey ssl/privkey.pem -out ssl/identity.p12 -name "hypha"

#Copy nginx SSL options
cp selfsigned/options-ssl-nginx.conf ssl/options-ssl-nginx.conf

#Add private key password to nginx configuration file
echo "$PASSPHRASE" > ssl/ssl_passwords
echo "ssl_password_file /etc/ssl/ssl_passwords;" >> ssl/options-ssl-nginx.conf

docker restart hub-auth hypha-gateway
