terraform {
  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}


# Set DOPPLER_TOKEN environment variable for a Service Account
# with permissions for managing Service Accounts and Projects.
provider "doppler" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

variable "kubernetes_apps_namespace" {
  description = "Kubernetes namespace where applications are deployed"
  type        = string
  default     = ""
}

variable "kubernetes_oidc_issuer_url" {
  description = "OIDC Issuer URL for the Kubernetes cluster (root URL, not the .well-known path)"
  type        = string
  default     = ""
}

variable "doppler_service_account_name" {
  description = "Doppler Kubernetes Operator Service Account name."
  type        = string
}

variable "doppler_projects" {
  description = "Doppler projects to sync."
  type        = set(string)
}

variable "doppler_environment" {
  description = "Doppler environment in each project to sync."
  type        = string
}