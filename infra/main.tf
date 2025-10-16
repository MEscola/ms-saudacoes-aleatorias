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


locals {
  # Garante que o nome do app tenha no máximo 23 caracteres
  safe_tag = substr(var.docker_image_tag, 0, 8) # corta tag grande
  unique_app_name = substr("${var.app_name}-${local.safe_tag}", 0, 23)
}


resource "koyeb_app" "my_app" {
  name = local.unique_app_name
}

resource "koyeb_service" "my-service" {
  app_name = koyeb_app.my_app.name
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
  image = "${var.docker_image_name}:${var.docker_image_tag != "" ? var.docker_image_tag : "dev"}"
    }
  }

  depends_on = [
    koyeb_app.my_app
  ]
}