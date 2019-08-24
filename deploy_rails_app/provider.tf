
# Provider block left empty assuming that our kubectl is pointing
# to our newly created EKS cluster
# 
# If we wish to configure the provider statically, that is done by 
# providing TLS certificates as Below:

# provider "kubernetes" {
#   host = "https://104.196.242.174"

#   client_certificate     = file("~/.kube/client-cert.pem")
#   client_key             = file("~/.kube/client-key.pem")
#   cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
# }

provider "kubernetes" {}
