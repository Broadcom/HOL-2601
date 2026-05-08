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