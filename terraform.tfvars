kubernetes_apps_namespace  = "apps"
kubernetes_oidc_issuer_url = "https://doppler-kubernetes.ngrok.dev"
doppler_service_account_name = "kubernetes-production"
doppler_environment = "prd"
doppler_projects = [
    "batch-processing-worker",
    "billing-service",
    "data-ingestion-service",
    "data-preprocessing-pipeline",
    "document-store-api",
    "llm-gateway",
    "logs-aggregator",
    "metrics-collector",
    "model-inference-api",
    "model-monitoring-service",
    "model-training-service",
    "notification-service",
    "object-storage-proxy",
    "rate-limiter-service",
    "redis-cache-service",
    "user-auth-service",
    "vector-embedding-service",
    "web-api-gateway"
  ]
