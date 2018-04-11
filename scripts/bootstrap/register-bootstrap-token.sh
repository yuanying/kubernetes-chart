#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
LOCAL_KUBE_MANIFESTS_DIR="${ROOT}/../../manifests"
KUBE_API_SERVICE_EXTERNAL_IP=${KUBE_API_SERVICE_EXTERNAL_IP:-"192.168.11.101"}

export KUBE_CONFIG=${KUBE_ADMIN_KUBECONFIG:-"${LOCAL_KUBE_MANIFESTS_DIR}/admin.yaml"}

# FIXME(yuanying): Make following code work with Linux
TOKEN_EXPIRATION_DATE=$(date -v +2d -u +"%Y-%m-%dT%H:%M:%SZ")
TOKEN_ID=$(openssl rand -hex 3)
TOKEN_SECRET=$(openssl rand -hex 8)

ENCODED_TOKEN_EXPIRATION_DATE=$(echo -n "${TOKEN_EXPIRATION_DATE}" | base64 | tr -d '\n')
ENCODED_TOKEN_ID=$(echo -n "${TOKEN_ID}" | base64 | tr -d '\n')
ENCODED_TOKEN_SECRET=$(echo -n "${TOKEN_SECRET}" | base64 | tr -d '\n')

echo "[bootstraptoken] Using token: ${TOKEN_ID}.${TOKEN_SECRET}"

cat << EOF | kubectl create -f -
apiVersion: v1
data:
  auth-extra-groups: c3lzdGVtOmJvb3RzdHJhcHBlcnM6a3ViZWFkbTpkZWZhdWx0LW5vZGUtdG9rZW4=
  description: VGhlIGRlZmF1bHQgYm9vdHN0cmFwIHRva2VuIGdlbmVyYXRlZCBieSAna3ViZXJuZXRlcy1jaGFydCcu
  expiration: ${ENCODED_TOKEN_EXPIRATION_DATE}
  token-id: ${ENCODED_TOKEN_ID}
  token-secret: ${ENCODED_TOKEN_SECRET}
  usage-bootstrap-authentication: dHJ1ZQ==
  usage-bootstrap-signing: dHJ1ZQ==
kind: Secret
metadata:
  name: bootstrap-token-${TOKEN_ID}
  namespace: kube-system
type: bootstrap.kubernetes.io/token
EOF

echo
echo "kubeadm join --token ${TOKEN_ID}.${TOKEN_SECRET} ${KUBE_API_SERVICE_EXTERNAL_IP}:443 --discovery-token-unsafe-skip-ca-verification"
