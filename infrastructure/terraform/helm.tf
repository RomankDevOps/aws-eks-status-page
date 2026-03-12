provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.10.0"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  # The production fix we discussed: Disables the strict validation webhook
  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }
}

resource "helm_release" "status_page_app" {
  name             = "status-page"
  chart            = "../../helm/status-page"
  namespace        = "default"
  create_namespace = true
  wait             = false # Allows pipeline to continue to Docker build even if image is missing

  depends_on = [helm_release.ingress_nginx]
}
