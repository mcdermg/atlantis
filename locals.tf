/*
Copyright 2022 Google. This software is provided as-is, without warranty or representation for any use or purpose.
Your use of it is subject to your agreement with Google.
*/

locals {
  subnet_name = "${var.environment}-subnet"
  subnet_key  = "${var.region}/${local.subnet_name}"

  subnets = [
    {
      ip_cidr_range = var.subnet["ip_cidr_range"]
      name          = local.subnet_name
      region        = var.region
      secondary_ip_range = {
        pods     = var.subnet["pods_cidr_range"]
        services = var.subnet["services_cidr_range"]
      }
    }
  ]

  subnets_proxy_only = [
    {
      ip_cidr_range = var.subnet_proxy_only_cidr_range
      name          = "proxy-only-subnet"
      region        = var.region
      active        = true
    }
  ]

  psa_config = {
    ranges = { myrange = var.subnet_psa_cidr_range }
    routes = null
  }

  firewall_rules = {
    gke-ingress = {
      description          = "GKE Ingress rule, port same as ClusterIP Service"
      direction            = "INGRESS"
      action               = "allow"
      sources              = []
      ranges               = [var.subnet_proxy_only_cidr_range]
      targets              = []
      use_service_accounts = false
      rules                = [{ protocol = "tcp", ports = [80, 443, 8080] }]
      extra_attributes     = {}
    }
    gke-rdp-access = {
      description          = "GKE Ingress rule for RDP access via IAP to winodws nodes"
      direction            = "INGRESS"
      action               = "allow"
      sources              = []
      ranges               = ["35.235.240.0/20"]
      targets              = []
      use_service_accounts = false
      rules                = [{ protocol = "tcp", ports = [3389] }]
      extra_attributes     = {}
    }
    # TO DO IAP SSH Linux nodes rule
  }
  # all_project_services = concat(var.gcp_service_list, [
  #   "serviceusage.googleapis.com",
  #   "iam.googleapis.com",
  # ])
}
