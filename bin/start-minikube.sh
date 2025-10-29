#!/bin/bash

# Minikube startup script with OIDC configuration for Doppler integration

echo "Starting minikube with OIDC configuration for Doppler..."

# Start minikube with OIDC service account issuer configuration
minikube start \
  --driver=docker \
  --extra-config=apiserver.service-account-issuer=https://doppler-kubernetes.ngrok.dev \
  --extra-config=apiserver.service-account-jwks-uri=https://doppler-kubernetes.ngrok.dev/openid/v1/jwks \
  --extra-config=apiserver.api-audiences=https://doppler-kubernetes.ngrok.dev \
  --cpus=2 \
  --memory=4g \
  --kubernetes-version=v1.30.0

echo "Minikube started successfully!"
echo "API Server URL: $(minikube ip):8443"
echo "Service Account Issuer: https://doppler-kubernetes.ngrok.dev"
echo "JWKS URI: https://doppler-kubernetes.ngrok.dev/openid/v1/jwks"

# Verify OIDC configuration
echo "Verifying OIDC discovery configuration..."
kubectl get --raw /.well-known/openid-configuration | jq .