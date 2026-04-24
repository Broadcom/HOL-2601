variable "nsx_wld01_manager_url" {
  type        = string
  description = "The NSX Manager URL for WLD01 to connect to"
  default     = "nsx-wld01-a.site-a.vcf.lab"
}

variable "nsx_wld01_manager_username" {
  type        = string
  description = "The username for the NSX Manager for WLD01"
  default     = "admin"
}
variable "nsx_wld01_manager_password" {
  type        = string
  description = "The password for the NSX Manager for WLD01"
  sensitive   = true
}

variable "nsx_wld01_project" {
  type        = string
  description = "The NSX-T project to use for VCFA"
  default     = "hol-all-apps"
}

variable "nsx_wld01_tier0_gateway_name" {
  type        = string
  description = "The name of the NSX Tier-0 gateway"
}
variable "nsx_wld01_edge_cluster_name" {
  type        = string
  description = "The name of the NSX edge cluster"
}