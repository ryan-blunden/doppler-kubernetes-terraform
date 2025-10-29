#!/usr/bin/env just

set shell := ["bash", "-c"]

default:
    @just --list

minikube-start:
  @./bin/start-minikube.sh

minikube-stop:
  @minikube stop

ngrok:
  @ngrok http https://$(minikube ip):8443 --domain=doppler-kubernetes.ngrok.dev --host-header=rewrite

install-doppler-operator:
  @helm repo add doppler https://helm.doppler.com
  @helm install --generate-name doppler/doppler-kubernetes-operator

uninstall-doppler-operator:
  @./bin/uninstall-doppler-operator.sh

doppler-controller-logs:
  @kubectl logs -n doppler-operator-system  -l control-plane=controller-manager   --follow --tail=500 -f

get-doppler-oidc-audience:
  @kubectl logs -n doppler-operator-system -l control-plane=controller-manager --tail=20 | grep -i audience

get-oidc-url:
  #!/usr/bin/env bash
  set -euo pipefail
  ISSUER_URL=$(kubectl get --raw /.well-known/openid-configuration | jq -r .issuer)
  echo "${ISSUER_URL}/.well-known/openid-configuration"

get-oidc-metadata:
  @curl -s -k $(just get-oidc-url) | jq .
