# Create Doppler Service Account for Kubernetes
resource "doppler_service_account" "kubernetes_operator" {
  name = var.doppler_service_account_name
  # Project environment access set via doppler_project_member_service_account resources.
  workplace_permissions = ["all_enclave_projects"]
}

# Grant the Kubernetes service account access to the supplied environment in each project
resource "doppler_project_member_service_account" "kubernetes_projects" {
  for_each = var.doppler_projects

  project              = each.value
  service_account_slug = doppler_service_account.kubernetes_operator.slug
  role                 = "viewer"
  environments         = [var.doppler_environment] # Only production environment access
}

# Create Kubernetes OIDC Identity
resource "doppler_service_account_identity" "kubernetes_operator" {
  service_account_slug = doppler_service_account.kubernetes_operator.slug
  name                 = "doppler-secrets-operator"
  ttl_seconds          = 3600
  config_oidc {
    discovery_url = var.kubernetes_oidc_issuer_url
    claims_type   = "wildcard"

    claims {
      key    = "aud"
      values = ["dopplerSecret:${var.kubernetes_apps_namespace}:*"]
    }

    claims {
      key    = "sub"
      values = ["system:serviceaccount:doppler-operator-system:doppler-operator-controller-manager"]
    }
  }
}

