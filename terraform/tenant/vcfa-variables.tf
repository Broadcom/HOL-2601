variable "password_file_path" {
  type        = string
  description = "The path to the file containing the password for the VCF Automation API"
  default     = "/home/holuser/creds.txt"
}
variable "vcfa_url" {
  type        = string
  description = "The VCF Automation URL"
  default     = "auto-a.site-a.vcf.lab"
}
variable "vcfa_insecure" {
  type        = bool
  description = "Whether to validate the VCF Automation TLS certificates"
  default     = "true"
}
variable "vcfa_refresh_token" {
  type        = string
  description = "The VCF Automation refresh token"
  sensitive   = true
}
variable "vcfa_username" {
  type        = string
  description = "The VCF Automation username"
  sensitive   = true
}
variable "vcfa_password" {
  type        = string
  description = "The VCF Automation password"
  sensitive   = true
}
variable "vcfa_org" {
  type        = string
  description = "The VCF Automation organization"
  sensitive   = true
}
variable "vcfa_log_file" {
  type        = string
  description = "The VCF Automation log file path"
  default     = "all-apps"
}

variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "apps-project"
}

variable "project_admins_group" {
  type        = string
}

variable "project_users_group" {
  type        = string
  
}
variable "namespace_name" {
  type        = string
  description = "The name of the Supervisor Namespace"
  default     = "apps-project"
}

variable "namespace_class" {
  type        = string
  description = "The Supervisor Namespace Class"
  default     = "small"
}
variable "namespace_region" {
  type        = string
  description = "The region where the Supervisor Namespace resides"
  default     = "region-a"
}
variable "namespace_vpc" {
  type        = string
  description = "The Supervisor Namespace VPC"
  default     = "region-a-default-vpc"
}
variable "namespace_class_storage_class_limit" {
  type        = string
  description = "The Supervisor Namespace Storage Class Limit"

}
variable "namespace_storage_class_name" {
  type        = string
  description = "The Supervisor Namespace Storage Class Name"
}
variable "namespace_class_cpu_limit" {
  type        = string
  description = "The Supervisor Namespace Class CPU limit"
}

variable "namespace_class_cpu_reservation" {
  type        = string
}
variable "namespace_class_memory_limit" {
  type        = string
}
variable "namespace_class_memory_reservation" {
  type        = string
}
variable "namespace_zone" {
  type        = string
  default     = "z-wld-a"
}
