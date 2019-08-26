# Kubernetes Secret used to store sensitive informations like passwords, keys
# that can be mounted as file or ENV variable in the Pod's containers

resource "kubernetes_secret" "rails_secrets" {
  metadata {
    name = "rails_secrets"
  }

  # Fetching and populating Secret Values from .tfvars file
  data = {
    for_each = "${toset(var.rails_env_variables.secret)}"
    "${each.key}" = "${each.value}"
  }

  type = "kubernetes.io/basic-auth"
}