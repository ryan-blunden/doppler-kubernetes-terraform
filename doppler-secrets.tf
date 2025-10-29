# Create DopplerSecret CRD resource for the supplied projects and environment
resource "kubernetes_manifest" "doppler_secret_crds" {
  for_each = var.doppler_projects

  manifest = {
    apiVersion = "secrets.doppler.com/v1alpha1"
    kind       = "DopplerSecret"
    metadata = {
      name      = "${each.value}-prd"
      namespace = var.kubernetes_apps_namespace
    }
    spec = {
      identity = doppler_service_account_identity.kubernetes_operator.id
      project  = each.value
      config   = "prd"
      managedSecret = {
        namespace = var.kubernetes_apps_namespace
        name      = "doppler-${each.value}-prd"
      }
    }
  }
}