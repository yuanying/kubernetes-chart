#!/usr/bin/env bash

set -eu
export LC_ALL=C


ROOT=$(dirname "${BASH_SOURCE}")
LOCAL_KUBE_CERTS_DIR="${ROOT}/../certs"

export CA_KEY=${KUBE_CA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/ca.key"}
export CA_CERT=${KUBE_CA_CERT:-"${LOCAL_KUBE_CERTS_DIR}/ca.crt"}
export CA_SERIAL=${KUBE_CA_SERIAL:-"${LOCAL_KUBE_CERTS_DIR}/ca.srl"}
export CA_DATABASE=${KUBE_CA_DATABASE:-"${LOCAL_KUBE_CERTS_DIR}/index.txt"}

export SA_KEY=${KUBE_SA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/sa.key"}
export SA_PUB_KEY=${KUBE_SA_KEY:-"${LOCAL_KUBE_CERTS_DIR}/sa.pub"}

export KUBE_APISERVER_KEY=${KUBE_APISERVER_KEY:-"${LOCAL_KUBE_CERTS_DIR}/apiserver.key"}
export KUBE_APISERVER_CERT=${KUBE_APISERVER_CERT:-"${LOCAL_KUBE_CERTS_DIR}/apiserver.crt"}
export KUBE_API_SERVICE_CLUSTER_IP=${KUBE_API_SERVICE_CLUSTER_IP:-"10.254.0.1"}
export KUBE_API_SERVICE_EXTERNAL_IP=${KUBE_API_SERVICE_EXTERNAL_IP:-"192.168.11.101"}
export KUBE_API_SERVICE_HOST_NAME=${KUBE_API_SERVICE_HOST_NAME:-"k8s.example.com"}

KUBE_CM_KEY=${KUBE_CM_KEY:-"${LOCAL_KUBE_CERTS_DIR}/controller-manager.key"}
KUBE_CM_CERT_REQ=${KUBE_CM_CERT_REQ:-"${LOCAL_KUBE_CERTS_DIR}/controller-manager.csr"}
KUBE_CM_CERT=${KUBE_CM_CERT:-"${LOCAL_KUBE_CERTS_DIR}/controller-manager.crt"}

KUBE_SCHEDULER_KEY=${KUBE_SCHEDULER_KEY:-"${LOCAL_KUBE_CERTS_DIR}/scheduler.key"}
KUBE_SCHEDULER_CERT_REQ=${KUBE_SCHEDULER_CERT_REQ:-"${LOCAL_KUBE_CERTS_DIR}/scheduler.csr"}
KUBE_SCHEDULER_CERT=${KUBE_SCHEDULER_CERT:-"${LOCAL_KUBE_CERTS_DIR}/scheduler.crt"}

KUBE_KUBELET_CLIENT_KEY=${KUBE_KUBELET_CLIENT_KEY:-"${LOCAL_KUBE_CERTS_DIR}/apiserver-kubelet-client.key"}
KUBE_KUBELET_CLIENT_CERT_REQ=${KUBE_KUBELET_CLIENT_CERT_REQ:-"${LOCAL_KUBE_CERTS_DIR}/apiserver-kubelet-client.csr"}
KUBE_KUBELET_CLIENT_CERT=${KUBE_KUBELET_CLIENT_CERT:-"${LOCAL_KUBE_CERTS_DIR}/apiserver-kubelet-client.crt"}

KUBE_ADMIN_KEY=${KUBE_ADMIN_KEY:-"${LOCAL_KUBE_CERTS_DIR}/admin.key"}
KUBE_ADMIN_CERT_REQ=${KUBE_ADMIN_CERT_REQ:-"${LOCAL_KUBE_CERTS_DIR}/admin.csr"}
KUBE_ADMIN_CERT=${KUBE_ADMIN_CERT:-"${LOCAL_KUBE_CERTS_DIR}/admin.crt"}

mkdir -p ${LOCAL_KUBE_CERTS_DIR}

source ${ROOT}/render-ca.sh
source ${ROOT}/render-sa-keypair.sh
# source ${ROOT}/render-admin-cert.sh
# source ${ROOT}/render-kubelet-client-cert.sh
source ${ROOT}/render-apiserver-cert.sh

export CLIENT_KEY=${KUBE_CM_KEY}
export CLIENT_CERT_REQ=${KUBE_CM_CERT_REQ}
export CLIENT_CERT=${KUBE_CM_CERT}
source ${ROOT}/render-client-cert.sh "/CN=system:kube-controller-manager"

export CLIENT_KEY=${KUBE_SCHEDULER_KEY}
export CLIENT_CERT_REQ=${KUBE_SCHEDULER_CERT_REQ}
export CLIENT_CERT=${KUBE_SCHEDULER_CERT}
source ${ROOT}/render-client-cert.sh "/CN=system:kube-scheduler"

export CLIENT_KEY=${KUBE_KUBELET_CLIENT_KEY}
export CLIENT_CERT_REQ=${KUBE_KUBELET_CLIENT_CERT_REQ}
export CLIENT_CERT=${KUBE_KUBELET_CLIENT_CERT}
source ${ROOT}/render-client-cert.sh "/O=system:masters/CN=kube-apiserver-kubelet-client"

export CLIENT_KEY=${KUBE_ADMIN_KEY}
export CLIENT_CERT_REQ=${KUBE_ADMIN_CERT_REQ}
export CLIENT_CERT=${KUBE_ADMIN_CERT}
source ${ROOT}/render-client-cert.sh "/O=system:masters/CN=kubernetes-admin"
