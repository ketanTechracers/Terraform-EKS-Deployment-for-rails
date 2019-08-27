resource "kubernetes_horizontal_pod_autoscaler" "rails_hpa" {
  metadata {
    name = "rails_hpa"
  }
  spec {
    max_replicas = 10
    min_replicas = 2
    scale_target_ref {
      kind = "Deployment"
      name = "rails_app_deployment"
    }
    metrics {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type = "Utilization"
          averageUtilization = "${var.rails_pod_cpu_utilization_limit}"
        }
      }
    }
  }
}