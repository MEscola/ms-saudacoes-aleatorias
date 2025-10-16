terraform {
  required_providers {
    koyeb = {
      source = "koyeb/koyeb"
    }
  }
}
provider "koyeb" {
  #
  # Use the KOYEB_TOKEN env variable to set your Koyeb API token.
  #
}

variable "app_name" {
  description = "Nome base do aplicativo"
  default     = "ms-saudacoes-aleatorias"
}

variable "service_name" {
  description = "Nome do serviço"
  default     = "saudacoes-service"
}

variable "container_port" {
  description = "Porta do container"
  default     = 8080
}

variable "docker_image_name" {
  description = "Nome da imagem Docker"
}

variable "docker_image_tag" {
  description = "Tag da imagem Docker"
}

locals {
  unique_app_name = "${var.app_name}-${var.docker_image_tag}"
}


resource "koyeb_app" "my_app" {
  name = local.unique_app_name
}

resource "koyeb_service" "my-service" {
  app_name = var.app_name
  definition {
    name = var.service_name
    instance_types {
      type = "free"
    }
    ports {
      port     = var.container_port
      protocol = "http"
    }
    scalings {
      min = 0
      max = 1
    }
    routes {
      path = "/"
      port = var.container_port
    }
    health_checks {
      http {
        port = var.container_port
        path = "/api/saudacoes/aleatorio"
      }
    }
    regions = ["was"]
    docker {
      image = "${var.docker_image_name}:${var.docker_image_tag}"
    }
  }

  depends_on = [
    koyeb_app.my-app
  ]
}