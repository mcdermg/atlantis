variable "project_id" {
  description = "The project ID that will host the infrastructure"
  type        = string
  default     = "dark-axe-359021"
}

variable "environment" {
  description = "Naming used in various places to signify the enviroment/clinet in use"
  type        = string
  default     = "development"
}

variable "region" {
  description = "The region in which to place the GKE cluster"
  type        = string
  default     = "us-central1"
}

variable "enablek8" {
  description = "Enable GKE"
  type        = bool
  default     = true
}

variable "enablelinuxk8" {
  description = "Enable GKE Linux node pool"
  type        = bool
  default     = true
}

variable "enablewink8" {
  description = "Enable GKE Windows node pool"
  type        = bool
  default     = true
}

variable "enablecloudsql" {
  description = "Enable the CloudSQL instance or not"
  type        = bool
  default     = true
}

variable "subnet" {
  description = "The subnet ranges to be used for the primary and secondary ranges"
  type        = map(any)
  default = {
    ip_cidr_range       = "10.0.0.0/16"
    pods_cidr_range     = "192.168.0.0/17"
    services_cidr_range = "192.168.128.0/17"
  }
}

variable "subnet_proxy_only_cidr_range" {
  description = "The range to be used in the subnet as the proxy only range"
  type        = string
  default     = "10.129.0.0/23"
}

variable "subnet_psa_cidr_range" {
  description = "The range to be used in the subnet as the psa range"
  type        = string
  default     = "10.100.16.0/24"
}

variable "cloud_nat_name" {
  description = "Name to be used ffor the cloud nat resource"
  type        = string
  default     = "cloud-nat"
}

# TODO change default network to a range that aligns with Avalara's networking in its non edge GCP organization
variable "authorized_networks" {
  description = "A list of whitelisted IP addresses for Cloud SQL"
  type        = list(any)
  default = [
    { name = "net1", value = "1.2.3.4/32" },
    { name = "net2", value = "5.6.7.8/32" },
    { name = "net3", value = "1.1.1.1/32" },
    { name = "net4", value = "2.2.2.2/32" },
  ]
}

variable "gke_cluster_name" {
  description = "Default name for GKE cluster"
  type        = string
  default     = "cluster"
}

variable "gke_master_cidr_range" {
  description = "The GKE master network cider range"
  type        = string
  default     = "172.16.0.16/28"
}

variable "gke_enable_private_endpoint" {
  description = "Whether to enable the private endpoint"
  type        = bool
  default     = false
}

variable "gke_enable_private_nodes" {
  description = "Whether to enable private nodes"
  type        = bool
  default     = true
}

variable "gke_linux_node_pool" {
  description = "Linux node pool specs"
  type        = map(any)
  default = {
    name               = "linux-node-pool"
    machine_type       = "g1-small"
    gke_version        = "1.22.11-gke.400"
    initial_node_count = 2
    min_count          = 1
    max_count          = 3
    max_surge          = 0
    max_unavailable    = 0
    disk_size          = 100
    disk_type          = "pd-ssd"
    image_type         = "COS_CONTAINERD"
    auto_repair        = true
    auto_upgrade       = false
    preemptible        = false
  }
}

variable "gke_windows_node_pool" {
  description = "Windows node pool specs"
  type        = map(any)
  default = {
    name               = "windows-node-pool"
    machine_type       = "n1-standard-2"
    gke_version        = "1.22.11-gke.400"
    initial_node_count = 2
    min_count          = 1
    max_count          = 1
    max_surge          = 0
    max_unavailable    = 0
    disk_size          = 100
    disk_type          = "pd-ssd"
    image_type         = "WINDOWS_LTSC_CONTAINERD"
    auto_repair        = true
    auto_upgrade       = false
    preemptible        = false
  }
}

variable "gke_version" {
  description = "Version of kubernetes to use for control pane and node pools"
  type        = string
  default     = "1.23.5-gke.1503"
}

variable "cloudsql_name" {
  description = "Default name for Cloudsql"
  type        = string
  default     = "db"
}

variable "cloudsql_version" {
  description = "The version of MSSQL to use in the creation of the cloud SQL instance"
  type        = string
  default     = "SQLSERVER_2017_STANDARD"
}

variable "cloudsql_tier" {
  description = "The instance type/tier that is to be used in the creation of the cloud SQL instance"
  type        = string
  default     = "db-custom-8-52480"
}

variable "cloudsql_disk_size" {
  description = "The size of the disk used int he creation of the cloud SQL instance"
  type        = string
  default     = "300"
}

variable "cloudsql_disk_type" {
  description = "The type of disk to use in the creation of the cloud SQL instance"
  type        = string
  default     = "PD_SSD"
}

variable "cloudsql_delete_protection" {
  description = "Whether to enable deleteion protection for the cloud SQL instance"
  type        = bool
  default     = true
}

variable "cloudsql_backup_configuration" {
  description = "Ther backup configuation to be used inthe cloud SQL instance"
  type        = map(any)
  default = {
    enabled            = true
    binary_log_enabled = false
    start_time         = "23:00"
    location           = null
    log_retention_days = 7
    retention_count    = 7
  }
}

variable "cloudsql_users" {
  description = "Users to provision for the cloud SQL instacne, these are in addition to the manditory root user"
  type        = map(string)
  default     = null
}

# variable "cloudsql_root_password" {
#   description = "The password to be used for the root user ion the cloud SQL instance"
#   type        = string
#   sensitive   = true
# }

variable "cloudsql_availability_type" {
  description = "The type of availability to use on the cloud SQL instance"
  type        = string
  default     = "REGIONAL"
}

variable "cloudsql_databases" {
  description = "Databases to create once the primary instance is created."
  type        = list(string)
  default     = null
}
