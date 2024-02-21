variable "domain" {
  description = "The domain name for the website."
  type        = string
}

variable "google_client_id" {
  description = "The Google client ID."
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "The Google client secret."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "(Optional) The AWS region to create resources. Default is ca-central-1."
  default     = "ca-central-1"
  type        = string
}