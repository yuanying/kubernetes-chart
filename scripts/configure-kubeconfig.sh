#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_CLUSTER_NAME=${1:-"k8s-cluster"}

ROOT=$(dirname "${BASH_SOURCE}")
LOCAL_KUBE_CERTS_DIR="${ROOT}/../certs"

KUBE_API_SERVICE_EXTERNAL_IP=${KUBE_API_SERVICE_EXTERNAL_IP:-"192.168.11.101"}
KUBE_API_ENDPOINT=https://${KUBE_API_SERVICE_EXTERNAL_IP}:443

KUBE_CA_CERT=$(cat ${KUBE_CA_CERT:-"${LOCAL_KUBE_CERTS_DIR}/ca.crt"}| base64 | tr -d '\n')
KUBE_ADMIN_KEY=$(cat ${KUBE_ADMIN_KEY:-"${LOCAL_KUBE_CERTS_DIR}/admin.key"}| base64 | tr -d '\n')
KUBE_ADMIN_CERT=$(cat ${KUBE_ADMIN_CERT:-"${LOCAL_KUBE_CERTS_DIR}/admin.crt"}| base64 | tr -d '\n')


kubectl config set-cluster ${KUBE_CLUSTER_NAME} \
  --server ${KUBE_API_ENDPOINT}

kubectl config set \
  clusters.${KUBE_CLUSTER_NAME}.certificate-authority-data \
  "${KUBE_CA_CERT}"

kubectl config set-credentials ${KUBE_CLUSTER_NAME}-admin

kubectl config set \
  users.${KUBE_CLUSTER_NAME}-admin.client-certificate-data \
  "${KUBE_ADMIN_CERT}"

kubectl config set \
  users.${KUBE_CLUSTER_NAME}-admin.client-key-data \
  "${KUBE_ADMIN_KEY}"

kubectl config set-context ${KUBE_CLUSTER_NAME} \
  --cluster=${KUBE_CLUSTER_NAME} \
  --user=${KUBE_CLUSTER_NAME}-admin

kubectl config use-context ${KUBE_CLUSTER_NAME}
