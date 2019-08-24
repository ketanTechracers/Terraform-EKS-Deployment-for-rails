resource "kubernetes_service" "rails_lb" {
  metadata {
    name = "rails-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.rails_app_deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.rails_lb.load_balancer_ingress[0].ip
}