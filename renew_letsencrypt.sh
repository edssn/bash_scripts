#!/bin/bash

# This script takes a list of domains as arguments
# and will setup a single certificate for all of them.

cert_name="upaulavirtual.upacifico.edu.ec"
haproxy_cert_dir="/etc/pki/tls/certs"
email="julian.salazar@upacifico.edu.ec"

domains="-d $cert_name"
#domains=""
#for domain in "$@"
#do
#  domains+="-d $domain "
#done

certbot certonly --standalone --agree-tos --non-interactive \
-m $email --preferred-challenges http \
--http-01-port 8888 --cert-name $cert_name \
--renew-with-new-domains --keep-until-expiring $domains

#mkdir -p $haproxy_cert_dir

# Combine the certificate chain and private key and put it
# into the correct HAProxy directory
cd /etc/letsencrypt/live/$cert_name
cat fullchain.pem privkey.pem > "$haproxy_cert_dir/cert.pem"

echo "Reloading haproxy"
