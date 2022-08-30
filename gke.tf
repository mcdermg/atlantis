
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "cluster" {
  source = "./modules/gke-cluster"
  count  = var.enablek8 ? 1 : 0

  project_id                = var.project_id
  name                      = lower("Atlantis-cluster")
  location                  = var.region
  release_channel           = "UNSPECIFIED"
  min_master_version        = "1.23.5-gke.1503"
  network                   = module.vpc.name
  subnetwork                = module.vpc.subnets[local.subnet_key].name
  secondary_range_pods      = module.vpc.subnets[local.subnet_key].secondary_ip_range[0]["range_name"]
  secondary_range_services  = module.vpc.subnets[local.subnet_key].secondary_ip_range[1]["range_name"]
  default_max_pods_per_node = 32
  master_authorized_ranges = {
    internal-vms = module.vpc.subnets[local.subnet_key].ip_cidr_range
    external     = "186.22.152.169/32"
    office       = "104.132.57.95/32"
  }
  private_cluster_config = {
    enable_private_nodes    = var.gke_enable_private_nodes
    enable_private_endpoint = var.gke_enable_private_endpoint
    master_ipv4_cidr_block  = var.gke_master_cidr_range
    master_global_access    = false
  }
  addons  = {
    cloudrun_config            = false
    dns_cache_config           = false
    horizontal_pod_autoscaling = true
    http_load_balancing        = true
    istio_config = {
      enabled = false
      tls     = false
    }
    network_policy_config                 = false
    gce_persistent_disk_csi_driver_config = true
    gcp_filestore_csi_driver_config       = false
    config_connector_config               = false
    kalm_config                           = false
    gke_backup_agent_config               = false
  }
  labels = {
    environment = "test"
  }
}

module "linux_nodepool" {
  source = "./modules/gke-nodepool"
  count  = var.enablelinuxk8 ? 1 : 0

  project_id                  = var.project_id
  cluster_name                = try(module.cluster[0].name, "")
  location                    = module.vpc.subnets[local.subnet_key].region
  initial_node_count          = var.gke_linux_node_pool["initial_node_count"]
  name                        = var.gke_linux_node_pool["name"]
  node_machine_type           = var.gke_linux_node_pool["machine_type"]
  node_disk_size              = var.gke_linux_node_pool["disk_size"]
  node_disk_type              = var.gke_linux_node_pool["disk_type"]
  node_image_type             = var.gke_linux_node_pool["image_type"]
  node_preemptible            = var.gke_linux_node_pool["preemptible"]
  node_service_account_create = true
  gke_version                 = var.gke_linux_node_pool["gke_version"]

  management_config = {
    auto_repair  = var.gke_linux_node_pool["auto_repair"]
    auto_upgrade = var.gke_linux_node_pool["auto_upgrade"]
  }

  autoscaling_config = {
    min_node_count = var.gke_linux_node_pool["min_count"]
    max_node_count = var.gke_linux_node_pool["max_count"]
  }

  upgrade_config = {
      max_surge       = var.gke_linux_node_pool["max_surge"]
      max_unavailable = var.gke_linux_node_pool["max_unavailable"]
  }
}

module "nodepool_windows" {
  source = "./modules/gke-nodepool"
  count  = var.enablewink8 ? 1 : 0

  project_id                  = var.project_id
  cluster_name                = try(module.cluster[0].name, "")
  location                    = module.vpc.subnets[local.subnet_key].region
  name                        = var.gke_windows_node_pool["name"]
  initial_node_count          = var.gke_windows_node_pool["initial_node_count"]
  node_machine_type           = var.gke_windows_node_pool["machine_type"]
  node_disk_size              = var.gke_windows_node_pool["disk_size"]
  node_disk_type              = var.gke_windows_node_pool["disk_type"]
  node_image_type             = "WINDOWS_SAC_CONTAINERD" # var.gke_windows_node_pool["image_type"]
  node_preemptible            = var.gke_windows_node_pool["preemptible"]
  node_service_account_create = true
  gke_version                 = "1.24.2-gke.1900" # var.gke_windows_node_pool["gke_version"]
  node_metadata               = {
    "windows-startup-script-url" = "https://storage.googleapis.com/ibrahimab-public/update_containerd_166.ps1"
    "disable-legacy-endpoints"   = "true"
  }

  management_config = {
    auto_repair  = var.gke_windows_node_pool["auto_repair"]
    auto_upgrade = var.gke_windows_node_pool["auto_upgrade"]
  }
  autoscaling_config = {
    min_node_count = var.gke_windows_node_pool["min_count"]
    max_node_count = var.gke_windows_node_pool["max_count"]
  }
  upgrade_config = {
      max_surge       = var.gke_windows_node_pool["max_surge"]
      max_unavailable = var.gke_windows_node_pool["max_unavailable"]
  }
  depends_on = [
    module.linux_nodepool
  ]
}
