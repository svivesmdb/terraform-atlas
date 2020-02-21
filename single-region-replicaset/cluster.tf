#
# This is an example on how to deploy single-region clusters
# using terraform. The lines below are just for configuration
# purposes.
#  Usage:
#   terraform apply 
#   to use the default values on the script (modify them as you want)
#  Or use:
#   terraform apply -var 'cluster_name="MyCluster"' -var 'cloud_provider="AZURE"' -var 'region_name="UK_SOUTH"'
#   to dynamically pass the variables.
#
module "atlasconfig" {
  source = "../modules/atlasconfig"
}
provider "mongodbatlas" {
  public_key = module.atlasconfig.atlas_project_publickey
  private_key  = module.atlasconfig.atlas_project_private_key
}

# Change this to customize your deployment 
variable "cluster_name" {default="MyNewCluster"}
variable "cluster_size" {default= "M30"}
variable "mongodb_version" {default= "4.0"}
variable "cloud_provider" {default= "AWS"} # Can be one of these: AWS, GCP, AZURE
variable "region_name" {default= "EU_WEST_2"}
# Region names? Can be found here
# https://docs.atlas.mongodb.com/cloud-providers-regions/




resource "mongodbatlas_cluster" "single-region-cluster" {
  project_id   = module.atlasconfig.atlas_projectid
  
  num_shards                    = 1
  replication_factor            = 3

  # This is continuous backup
  backup_enabled                = false
  # This is the CPS-based backup
  provider_backup_enabled       = true
  auto_scaling_disk_gb_enabled  = true
  
  name                          = "${var.cluster_name}"
  mongo_db_major_version        = "${var.mongodb_version}"
  provider_name                 = "${var.cloud_provider}"
  provider_instance_size_name   = "${var.cluster_size}"
  provider_region_name          = "${var.region_name}"
}