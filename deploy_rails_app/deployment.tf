resource "kubernetes_deployment" "rails_app_deployment" {
  metadata {
    name = "scalable-rails-example"
    labels = {
      App = "ScalableRailsExample"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "ScalableRailsExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableRailsExample"
        }
      }
      spec {
        container {
          image = "ketanstechracers/rails-dockerized:0.0.2"
          name  = "example"

          port {
            container_port = 80
          }

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
        }
      }
    }
  }
}
