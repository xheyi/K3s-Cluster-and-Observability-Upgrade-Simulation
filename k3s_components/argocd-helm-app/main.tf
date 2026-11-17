resource "kubernetes_manifest" "application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = var.app_name
      namespace = "argocd"
    }

    spec = {
      project = "default"

      source = {
        repoURL        = var.repo_url
        chart          = var.chart_name
        targetRevision = var.chart_version
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.namespace
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }

        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}