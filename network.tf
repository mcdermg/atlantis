/*
Copyright 2022 Google. This software is provided as-is, without warranty or representation for any use or purpose.
Your use of it is subject to your agreement with Google.
*/

module "vpc" {
  source = "./modules/net-vpc"

  project_id         = var.project_id
  name               = "${var.environment}-vpc"
  subnets            = local.subnets
  subnets_proxy_only = local.subnets_proxy_only
  psa_config         = local.psa_config
}

module "nat" {
  source = "./modules/net-cloudnat"

  project_id     = var.project_id
  region         = var.region
  name           = var.cloud_nat_name
  router_network = module.vpc.name
}

# Necessary for GKE Ingress
module "firewall" {
  source = "./modules/net-vpc-firewall"

  project_id          = var.project_id
  network             = module.vpc.name
  admin_ranges        = []
  http_source_ranges  = []
  https_source_ranges = []
  ssh_source_ranges   = []
  custom_rules        = local.firewall_rules
}


module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc.name

  rules = [{
    name                    = "allow-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = ["testing"]
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
  name                    = "egress"
  description             = null
  direction               = "EGRESS"
  priority                = null
  ranges                  = ["0.0.0.0/0"]
  source_tags             = null
  source_service_accounts = null
  target_tags             = null
  target_service_accounts = null
  allow = [{
    protocol = "tcp"
    ports    = ["22"]
  }]
  deny = []
  log_config = {
    metadata = "INCLUDE_ALL_METADATA"
  }
  }]
}
