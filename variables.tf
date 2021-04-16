# Xosphere Instance Orchestration Event Relay configuration
variable "event_relay_iam_role_arn" {
}

variable "event_router_sqs_url" {
}

variable "installed_region" {
}

variable "xosphere_version" {
}

variable "tags" {
  description = "Map of tag keys and values to be applied to objects created by this module (where applicable)"
  type = map
  default = {}
}