#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

bash ${ROOT}/bootstrap/register-rbac.sh
bash ${ROOT}/bootstrap/register-cluster-info.sh
bash ${ROOT}/bootstrap/register-kube-proxy.sh
bash ${ROOT}/bootstrap/register-flannel.sh
bash ${ROOT}/bootstrap/register-bootstrap-token.sh
