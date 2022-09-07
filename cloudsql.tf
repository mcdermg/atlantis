/*
Copyright 2022 Google. This software is provided as-is, without warranty or representation for any use or purpose.
Your use of it is subject to your agreement with Google.
*/

resource "random_password" "password" {
  length           = 20
  special          = true
  override_special = "()-_=+[]{}"
}

resource "random_string" "suffix" {
  length           = 5
  special          = false
}

module "cloud_sql" {
  source = "./modules/cloudsql-instance"
  count  = var.enablecloudsql ? 1 : 0

  project_id           = var.project_id
  network              = module.vpc.self_link
  name                 = lower("${var.environment}-${var.cloudsql_name}-${random_string.suffix.id}")
  region               = var.region
  database_version     = var.cloudsql_version
  tier                 = var.cloudsql_tier
  root_password        = random_password.password.result
  deletion_protection  = false #var.cloudsql_delete_protection
  backup_configuration = var.cloudsql_backup_configuration
  availability_type    = var.cloudsql_availability_type

  databases = var.cloudsql_databases
  users     = var.cloudsql_users
}
