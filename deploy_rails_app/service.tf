resource "kubernetes_service" "rails_load_balancer" {
  metadata {
    name = "rails-example"
  }
  spec {
    selector = {
      App = "${var.rails_deployment_label}"
    }
    port {
      port        = 80
      target_port = "${var.rails_env_variables.normal.port}"
    }

    type = "LoadBalancer"
  }
}

output "load_balancer_ip" {
  value = "${kubernetes_service.rails_load_balancer.load_balancer_ingress[0].ip}"
}