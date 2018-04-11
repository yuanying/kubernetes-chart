#!/usr/bin/env bash

set -eu
export LC_ALL=C


ROOT=$(dirname "${BASH_SOURCE}")
LOCAL_KUBE_MANIFESTS_DIR="${ROOT}/../manifests"
LOCAL_KUBE_SECRETS_DIR="${ROOT}/../secrets"
LOCAL_KUBE_CERTS_DIR="${ROOT}/../certs"

KUBE_API_SERVICE_EXTERNAL_IP=${KUBE_API_SERVICE_EXTERNAL_IP:-"192.168.11.101"}

KUBE_APISERVER_SECRET=${KUBE_APISERVER_SECRET:-"${LOCAL_KUBE_SECRETS_DIR}/apiserver-secret.yaml"}
KUBE_CM_SECRET=${KUBE_CM_SECRET:-"${LOCAL_KUBE_SECRETS_DIR}/cm-secret.yaml"}
KUBE_SCHEDULER_SECRET=${KUBE_SCHEDULER_SECRET:-"${LOCAL_KUBE_SECRETS_DIR}/scheduler-secret.yaml"}
KUBE_ADMIN_KUBECONFIG=${KUBE_ADMIN_KUBECONFIG:-"${LOCAL_KUBE_MANIFESTS_DIR}/admin.yaml"}

CA_KEY=${KUBE_CA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/ca.key"}
CA_CERT=${KUBE_CA_CERT:-"${LOCAL_KUBE_CERTS_DIR}/ca.crt"}
SA_KEY=${KUBE_SA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/sa.key"}
SA_PUB_KEY=${KUBE_SA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/sa.pub"}
KUBE_APISERVER_KEY=${KUBE_APISERVER_KEY:-"${LOCAL_KUBE_CERTS_DIR}/apiserver.key"}
KUBE_APISERVER_CERT=${KUBE_APISERVER_CERT:-"${LOCAL_KUBE_CERTS_DIR}/apiserver.crt"}
KUBE_CM_KEY=${KUBE_CM_KEY:-"${LOCAL_KUBE_CERTS_DIR}/controller-manager.key"}
KUBE_CM_CERT=${KUBE_CM_CERT:-"${LOCAL_KUBE_CERTS_DIR}/controller-manager.crt"}
KUBE_SCHEDULER_KEY=${KUBE_SCHEDULER_KEY:-"${LOCAL_KUBE_CERTS_DIR}/scheduler.key"}
KUBE_SCHEDULER_CERT=${KUBE_SCHEDULER_CERT:-"${LOCAL_KUBE_CERTS_DIR}/scheduler.crt"}
KUBE_KUBELET_CLIENT_KEY=${KUBE_KUBELET_CLIENT_KEY:-"${LOCAL_KUBE_CERTS_DIR}/apiserver-kubelet-client.key"}
KUBE_KUBELET_CLIENT_CERT=${KUBE_KUBELET_CLIENT_CERT:-"${LOCAL_KUBE_CERTS_DIR}/apiserver-kubelet-client.crt"}
KUBE_ADMIN_KEY=${KUBE_ADMIN_KEY:-"${LOCAL_KUBE_CERTS_DIR}/admin.key"}
KUBE_ADMIN_CERT=${KUBE_ADMIN_CERT:-"${LOCAL_KUBE_CERTS_DIR}/admin.crt"}

mkdir -p ${LOCAL_KUBE_SECRETS_DIR}
mkdir -p ${LOCAL_KUBE_MANIFESTS_DIR}

cat << EOF > ${KUBE_APISERVER_SECRET}
---
apiVersion: v1
data:
  apiserver.crt: $(cat ${KUBE_APISERVER_CERT} | base64 | tr -d '\n')
  apiserver.key: $(cat ${KUBE_APISERVER_KEY} | base64 | tr -d '\n')
  apiserver-kubelet-client.crt: $(cat ${KUBE_KUBELET_CLIENT_CERT} | base64 | tr -d '\n')
  apiserver-kubelet-client.key: $(cat ${KUBE_KUBELET_CLIENT_KEY} | base64 | tr -d '\n')
  ca.crt: $(cat ${CA_CERT} | base64 | tr -d '\n')
  service-account.pub: $(cat ${SA_PUB_KEY} | base64 | tr -d '\n')
kind: Secret
metadata:
  name: kube-apiserver
type: Opaque
EOF

cat << EOF > ${KUBE_CM_SECRET}
---
apiVersion: v1
data:
  controller-manager.crt: $(cat ${KUBE_CM_CERT} | base64 | tr -d '\n')
  controller-manager.key: $(cat ${KUBE_CM_KEY} | base64 | tr -d '\n')
  ca.crt: $(cat ${CA_CERT} | base64 | tr -d '\n')
  ca.key: $(cat ${CA_KEY} | base64 | tr -d '\n')
  service-account.key: $(cat ${SA_KEY} | base64 | tr -d '\n')
kind: Secret
metadata:
  name: kube-controller-manager
type: Opaque
EOF

cat << EOF > ${KUBE_SCHEDULER_SECRET}
---
apiVersion: v1
data:
  scheduler.crt: $(cat ${KUBE_SCHEDULER_CERT} | base64 | tr -d '\n')
  scheduler.key: $(cat ${KUBE_SCHEDULER_KEY} | base64 | tr -d '\n')
  ca.crt: $(cat ${CA_CERT} | base64 | tr -d '\n')
kind: Secret
metadata:
  name: kube-scheduler
type: Opaque
EOF

CA_DATA=$(cat ${CA_CERT} | base64 | tr -d '\n')
CLIENT_CERTS_DATA=$(cat ${KUBE_ADMIN_CERT} | base64 | tr -d '\n')
CLIENT_KEY_DATA=$(cat ${KUBE_ADMIN_KEY} | base64 | tr -d '\n')

cat << EOF > ${KUBE_ADMIN_KUBECONFIG}
apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    certificate-authority-data: ${CA_DATA}
    server: https://${KUBE_API_SERVICE_EXTERNAL_IP}:443
users:
- name: admin
  user:
    client-certificate-data: ${CLIENT_CERTS_DATA}
    client-key-data: ${CLIENT_KEY_DATA}
contexts:
- context:
    cluster: kubernetes
    user: admin
  name: admin-context
current-context: admin-context
EOF
