#
# This is an example on how to deploy single-region clusters
# using terraform. The lines below are just for configuration
# purposes.
#  Usage:
#   terraform apply 
#   to use the default values on the script (modify them as you want)
#  Or use:
#   terraform apply -var 'cluster_name="My cluster"' -var 'cloud_provider="AZURE"'
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
variable "cluster_name" {default="MultiRegion"}
variable "cluster_size" {default= "M10"}
variable "mongodb_version" {default= "4.0"}
variable "disk_size" {default= 100}
variable "disk_iops" {default= 300}

variable "cloud_provider" {default= "AWS"} # Can be one of these: AWS, GCP, AZURE
variable "cluster_region_nodes" {default= [3, 2, 2]}
variable "cluster_region_priority" {default= [7, 6, 5]}
variable "cluster_region_readonly_nodes" {default= [0, 0, 2]}
variable "cluster_region_analytics_nodes" {default= [1, 0, 1]}
variable "cluster_region_names" {default= ["EU_WEST_2", "US_EAST_2", "US_WEST_1"]}
# Region names? Can be found here
# https://docs.atlas.mongodb.com/cloud-providers-regions/



resource "mongodbatlas_cluster" "multi-region-cluster" {
  project_id                = module.atlasconfig.atlas_projectid
  
  name                      = "${var.cluster_name}"
  disk_size_gb             = "${var.disk_size}"
  num_shards               = 1
  provider_backup_enabled  = true
  cluster_type             = "REPLICASET"

  //Provider Settings "block"
  provider_name               = "${var.cloud_provider}"
  provider_disk_iops          = "${var.disk_iops}"
  provider_volume_type        = "STANDARD"
  provider_instance_size_name = "${var.cluster_size}"

  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = "${var.cluster_region_names[0]}"
      electable_nodes = "${var.cluster_region_nodes[0]}"
      priority        = "${var.cluster_region_priority[0]}"
      analytics_nodes = "${var.cluster_region_analytics_nodes[0]}"
      read_only_nodes = "${var.cluster_region_readonly_nodes[0]}"
    }
    regions_config {
      region_name     = "${var.cluster_region_names[1]}"
      electable_nodes = "${var.cluster_region_nodes[1]}"
      priority        = "${var.cluster_region_priority[1]}"
      analytics_nodes = "${var.cluster_region_analytics_nodes[1]}"
      read_only_nodes = "${var.cluster_region_readonly_nodes[1]}"
    }
    regions_config {
      region_name     = "${var.cluster_region_names[2]}"
      electable_nodes = "${var.cluster_region_nodes[2]}"
      priority        = "${var.cluster_region_priority[2]}"
      analytics_nodes = "${var.cluster_region_analytics_nodes[2]}"
      read_only_nodes = "${var.cluster_region_readonly_nodes[2]}"
    }
  }
}