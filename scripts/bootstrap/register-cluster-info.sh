#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
LOCAL_KUBE_MANIFESTS_DIR="${ROOT}/../../manifests"
LOCAL_KUBE_CERTS_DIR="${ROOT}/../../certs"
KUBE_API_SERVICE_EXTERNAL_IP=${KUBE_API_SERVICE_EXTERNAL_IP:-"192.168.11.101"}
CA_CERT=${KUBE_CA_CERT:-"${LOCAL_KUBE_CERTS_DIR}/ca.crt"}

export KUBE_CONFIG=${KUBE_ADMIN_KUBECONFIG:-"${LOCAL_KUBE_MANIFESTS_DIR}/admin.yaml"}

echo '[bootstraptoken] Creating the "cluster-info" ConfigMap in the "kube-public" namespace'

cat <<EOF | kubectl create -f -
apiVersion: v1
data:
  kubeconfig: |
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: $(cat ${CA_CERT} | base64 | tr -d '\n')
        server: https://${KUBE_API_SERVICE_EXTERNAL_IP}:443
      name: ""
    contexts: []
    current-context: ""
    kind: Config
    preferences: {}
    users: []
kind: ConfigMap
metadata:
  name: cluster-info
  namespace: kube-public
EOF

cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kubeadm:bootstrap-signer-clusterinfo
  namespace: kube-public
rules:
- apiGroups:
  - ""
  resourceNames:
  - cluster-info
  resources:
  - configmaps
  verbs:
  - get
EOF

cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kubeadm:bootstrap-signer-clusterinfo
  namespace: kube-public
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kubeadm:bootstrap-signer-clusterinfo
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:anonymous
EOF
