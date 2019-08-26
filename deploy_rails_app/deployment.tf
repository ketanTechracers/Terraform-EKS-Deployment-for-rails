resource "kubernetes_deployment" "rails_app_deployment" {
  metadata {
    name = "rails_app_deployment"
    labels = {
      App = "ScalableRailsDeployment"
    }
  }

  # Dependencies that must be created prior to this Kubernetes Deployment
  depends_on = [
    "${aws_db_instance.db_server}",
    "${kubernetes_secret.rails_secrets}",
  ]

  spec {
    replicas = "${var.rails_number_of_instance}"
    selector {
      match_labels = {
        App = "${var.rails_deployment_label}"
      }
    }
    template {
      metadata {
        labels = {
          App = "${var.rails_deployment_label}"
        }
      }
      spec {
        container {
          image = "${var.rails_docker.image}:${var.rails_docker.tag}"
          name  = "rails_app"

          port {
            container_port = "${var.rails_env_variables.normal.port}"
          }
          
          # Mounting Sensitive Environment variables safely from Kubernetes Secret
          env {
            for_each = "${toset(var.rails_env_variables.secret)}"
            name = "${each.key}"
            valueFrom {
              secretKeyRef {
                name = "${kubernetes_secret.rails_secrets.name}"
                key  = "${each.key}"
              }
            }
          }

          # Mounting other non-sensitive variables directly as key, value pair
          env {
            for_each = "${toset(var.rails_env_variables.normal)}"
            name = "${each.key}"
            value = "${each.value}"
          }

          # Resource Usage limits 
          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          # Liveliness URL to check if pod is running by Replication Controller
          liveness_probe {
            http_get {
              path = "/_health"
              port = "${var.rails_env_variables.normal.port}"
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
