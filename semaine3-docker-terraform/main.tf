terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "~> 3.0"
        }
    }
}

provider "docker" {}

resource "docker_network" "sre-net-tf" {
    name = "sre-net-tf"
}

resource "docker_image" "app" {
  name = "sre-app:v2"
  keep_locally = true
}

resource "docker_container" "app" {
    name = "app-tf"
    image = docker_image.app.image_id
    networks_advanced {
        name = docker_network.sre-net-tf.name
    }
    ports {
        internal = 8000
        external = 8000
    }
}