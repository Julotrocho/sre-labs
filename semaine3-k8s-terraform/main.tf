terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "sre_app" {
  metadata {
    name = "sre-app-tf"
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "sre-app-tf"
      }
    }
    template {
      metadata {
        labels = {
          app = "sre-app-tf"
        }
      }
      spec {
        container {
          name  = "sre-app"
          image = "nginx"
        }
      }
    }
  }
}