#!/usr/bin/env bash

set -eu
export LC_ALL=C


ROOT=$(dirname "${BASH_SOURCE}")
LOCAL_KUBE_MANIFESTS_DIR="${ROOT}/../manifests"
LOCAL_KUBE_CERTS_DIR="${ROOT}/../certs"

export KUBE_APISERVER_SECRET=${KUBE_APISERVER_SECRET:-"${LOCAL_KUBE_MANIFESTS_DIR}/apiserver-secret.yaml"}
export KUBE_CM_SECRET=${KUBE_CM_SECRET:-"${LOCAL_KUBE_MANIFESTS_DIR}/cm-secret.yaml"}
export KUBE_SCHEDULER_SECRET=${KUBE_SCHEDULER_SECRET:-"${LOCAL_KUBE_MANIFESTS_DIR}/scheduler-secret.yaml"}

export CA_KEY=${KUBE_CA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/ca.key"}
export CA_CERT=${KUBE_CA_CERT:-"${LOCAL_KUBE_CERTS_DIR}/ca.crt"}
export SA_KEY=${KUBE_SA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/sa.key"}
export SA_PUB_KEY=${KUBE_SA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/sa.pub"}
export KUBE_APISERVER_KEY=${KUBE_APISERVER_KEY:-"${LOCAL_KUBE_CERTS_DIR}/apiserver.key"}
export KUBE_APISERVER_CERT=${KUBE_APISERVER_CERT:-"${LOCAL_KUBE_CERTS_DIR}/apiserver.crt"}
export KUBE_CM_KEY=${KUBE_CM_KEY:-"${LOCAL_KUBE_CERTS_DIR}/controller-manager.key"}
export KUBE_CM_CERT=${KUBE_CM_CERT:-"${LOCAL_KUBE_CERTS_DIR}/controller-manager.crt"}
export KUBE_SCHEDULER_KEY=${KUBE_SCHEDULER_KEY:-"${LOCAL_KUBE_CERTS_DIR}/scheduler.key"}
export KUBE_SCHEDULER_CERT=${KUBE_SCHEDULER_CERT:-"${LOCAL_KUBE_CERTS_DIR}/scheduler.crt"}

mkdir -p ${LOCAL_KUBE_MANIFESTS_DIR}

cat << EOF > ${KUBE_APISERVER_SECRET}
---
apiVersion: v1
data:
  apiserver.crt: $(cat ${KUBE_APISERVER_CERT} | base64 | tr -d '\n')
  apiserver.key: $(cat ${KUBE_APISERVER_KEY} | base64 | tr -d '\n')
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
