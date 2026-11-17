## monitoring namespace

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }

    name = "monitoring"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}


## metrics-server

module "metrics-server" {
  source = "../modules/argocd-helm-app"
  count  = var.install_metrics_server ? 1 : 0

  application_name = "metrics-server"
  namespace        = "kube-system"
  project          = var.argocd_project_name
  repository_url   = "https://kubernetes-sigs.github.io/metrics-server/"
  chart_name       = "metrics-server"
  chart_version    = "3.14.0"
  create_namespace = false
  depends_on       = [argocd_project.components]

  sync_policy = {
    automated = {
      prune       = true
      self_heal   = true
      allow_empty = false
    }
    sync_options = ["CreateNamespace=false", "ServerSideApply=true"]
  }

  values = yamlencode({
    apiService = {
      create = true
    }
    replicas = 1
  })
}