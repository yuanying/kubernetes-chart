#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

SERVER_SUBJECT="/CN=kube-apiserver"
SERVER_SANS="IP:127.0.0.1,IP:10.254.0.1"
SERVER_SANS="${SERVER_SANS},IP:${KUBE_API_SERVICE_EXTERNAL_IP},IP:${KUBE_API_SERVICE_CLUSTER_IP}"

DELIMITER=''
HOSTNAME=''
HOSTNAMES=${KUBE_API_SERVICE_HOST_NAME//./ }
for P in ${HOSTNAMES[@]}; do
  HOSTNAME=${HOSTNAME}${DELIMITER}${P}
  SERVER_SANS="${SERVER_SANS},DNS:${HOSTNAME}"
  DELIMITER='.'
done

KUBE_APISERVER_CERT_REQ=${KUBE_APISERVER_CERT_REQ:-"${KUBE_APISERVER_CERT}.csr"}
KUBE_APISERVER_CERT_CONF=${KUBE_APISERVER_CERT_CONF:-"${KUBE_APISERVER_CERT}.cnf"}

# Create config for server's csr
cat > ${KUBE_APISERVER_CERT_CONF} <<EOF
# [ ca ]
# default_ca          = CA_default
# [ CA_default ]
# serial              = ${CA_SERIAL}
# database            = ${CA_DATABASE}
[req]
req_extensions      = v3_req
distinguished_name  = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints    = CA:FALSE
keyUsage            = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage    = clientAuth, serverAuth
subjectAltName      = ${SERVER_SANS}
EOF

if [[ ! -f ${KUBE_APISERVER_KEY} ]]; then
    openssl genrsa -out "${KUBE_APISERVER_KEY}" 4096
fi

openssl req -new -key "${KUBE_APISERVER_KEY}" \
            -out "${KUBE_APISERVER_CERT_REQ}" \
            -subj "${SERVER_SUBJECT}" \
            -config ${KUBE_APISERVER_CERT_CONF}

openssl x509 -req -in "${KUBE_APISERVER_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -CAserial "${CA_SERIAL}" \
             -out "${KUBE_APISERVER_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${KUBE_APISERVER_CERT_CONF}
