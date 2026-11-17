locals {
  helm_apps = {
    kube-prometheus-stack = {
      repo_url      = "https://prometheus-community.github.io/helm-charts"
      chart_name    = "kube-prometheus-stack"
      chart_version = "89.2.4"
      namespace     = "monitoring"
    }

    loki = {
      repo_url      = "https://grafana.github.io/helm-charts"
      chart_name    = "loki"
      chart_version = "6.27.0"
      namespace     = "monitoring"
    }

    alloy = {
      repo_url      = "https://grafana.github.io/helm-charts"
      chart_name    = "alloy"
      chart_version = "1.11.0"
      namespace     = "monitoring"
    }

    falco = {
      repo_url      = "https://falcosecurity.github.io/charts"
      chart_name    = "falco"
      chart_version = "6.4.1"
      namespace     = "falco"
    }

    vpa = {
      repo_url      = "https://charts.fairwinds.com/stable"
      chart_name    = "vpa"
      chart_version = "4.7.2"
      namespace     = "vpa"
    }

    opencost = {
      repo_url      = "https://opencost.github.io/opencost-helm-chart"
      chart_name    = "opencost"
      chart_version = "1.19.2"
      namespace     = "opencost"
    }
  }
}

module "helm_apps" {
  for_each = local.helm_apps

  source = "./modules/argocd-application"

  app_name      = each.key
  repo_url      = each.value.repo_url
  chart_name    = each.value.chart_name
  chart_version = each.value.chart_version
  namespace     = each.value.namespace
}