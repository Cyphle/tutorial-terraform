provider "kubernetes" {
  config_path     = "~/.kube.config"
  context_context = "docker-desktop"
}

module "simple_webapp" {
  source = "../../modules/services/k8s-app"

  name           = "simple_webapp"
  image          = "training/webapp"
  replicas       = 2
  container_port = 5000

  environment_variables {
    PROVIDER = "Terraform"
  }
}
