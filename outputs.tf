output "doppler_oidc_service_identity_id" {
  description = "Doppler Service Account OIDC Identity ID"
  value       = doppler_service_account_identity.kubernetes_operator.id
  sensitive   = false
}

output "doppler_operator_oidc_configuration" {
  description = "OIDC configuration details"
  value = {
    issuer   = var.kubernetes_oidc_issuer_url
    audience = "dopplerSecret:${var.kubernetes_apps_namespace}:*"
    subject  = "system:serviceaccount:doppler-operator-system:doppler-operator-controller-manager"
  }
  sensitive = false
}