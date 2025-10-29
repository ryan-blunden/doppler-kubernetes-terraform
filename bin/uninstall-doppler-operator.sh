#!/usr/bin/env bash

set -euo pipefail
kubectl delete dopplersecrets --all --all-namespaces || true

# Uninstall the first matching release
release_name=$(helm list -f doppler-kubernetes-operator --short | head -n 1)
if [ -n "$release_name" ]; then
  echo "Uninstalling $release_name..."
  helm uninstall "$release_name" || true
fi

kubectl delete namespace doppler-operator-system || true
kubectl delete clusterrolebinding doppler-operator-manager-rolebinding || true
kubectl delete clusterrole doppler-operator-manager-role || true
helm repo remove doppler || true