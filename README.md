# Secrets Infrastructure As Code with Doppler, Terraform, and Kubernetes

Reference impplementation for using Terraform to provision a Doppler service account for Kubernetes secrets sync using an OpenID Connect identity and automating the creation `DopplerSecret` CRDs in a Kubernetes cluster for a list of defined projects and specified environment.

## Prerequisites

- Terraform 1.5+
- Doppler service token exported as `DOPPLER_TOKEN` with rights to list projects and manage service accounts
- Access to the target Kubernetes cluster via `~/.kube/config` (or configure the Kubernetes Terraform provider accordingly)
- Optional (for local testing): `just`, `minikube`, `helm`, `ngrok`, `jq`

## Configuration

Edit `terraform.tfvars`
- `kubernetes_apps_namespace` – namespace that will own the managed Kubernetes secrets
- `kubernetes_oidc_issuer_url` – cluster OIDC issuer root URL (no `/.well-known` suffix)
- `doppler_service_account_name` – name for the Doppler service account dedicated to Kubernetes
- `doppler_environment` – Doppler config/environment
- `doppler_projects` – set of Doppler projects

## Usage

```bash
# Install the Doppler Kubernetes Operator
helm repo add doppler https://helm.doppler.com
helm install --generate-name doppler/doppler-kubernetes-operator

export DOPPLER_TOKEN=dp.st.xxxxxx       # service token with required access
terraform init
terraform plan
terraform apply
```

The Terraform resources:

1. Create a Doppler service account for syncing secrets to a Kubernetes cluster.
2. Configure the service account to have read-only access to the listed projects for the specified environment.
3. Create an OIDC identity for the Doppler Kubernetes service account.
4. Iterate through the list of projects to create `DopplerSecret` CRDs for each project and specified environment.

## Local Testing

Install dependencies:

```sh
brew install minikube helm jq just
brew install --cask ngrok
```

The `justfile` contains commands for local testing and debugging:

- `just minikube-start` – boot Minikube preconfigured with the required OIDC issuer/audience settings.
- `just install-doppler-operator` – install the Doppler Kubernetes Operator via Helm (repository assumed to be added).
- `just ngrok` – expose the Minikube API server through the hostname used in the sample vars.
- `just uninstall-doppler-operator` – cleanly remove the operator and related resources.

## Outputs

`terraform apply` surfaces the Doppler service account slug, the created service identity UUID, and the issuer/audience/subject values used in the OIDC configuration for easy cross-checking.
