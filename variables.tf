# Xosphere Instance Orchestration Event Relay configuration
variable "event_relay_iam_role_arn" {
}

variable "event_router_sqs_url" {
}

variable "installed_region" {
}

variable "xosphere_version" {
}

variable "notification_event_instance_states" {
  type = list
  default = [
    "pending",
    "terminated",
    "stopped"
  ]
}

variable "tags" {
  description = "Map of tag keys and values to be applied to objects created by this module (where applicable)"
  type = map
  default = {}
}







































## for internal use only
variable "instance_orchestrator_group_inspector_ec2_state_change_cloudwatch_event_lambda_permission_name_override" {
  description = "An explicit name to use"
  default = null
}

variable "instance_orchestrator_group_inspector_tag_change_cloudwatch_event_lambda_permission_name_override" {
  description = "An explicit name to use"
  default = null
}

variable "instance_orchestrator_scheduler_tag_change_cloudwatch_event_lambda_permission_name_override" {
  description = "An explicit name to use"
  default = null
}

variable "instance_orchestrator_terminator_cloudwatch_event_lambda_permission_name_override" {
  description = "An explicit name to use"
  default = null
}

variable "instance_orchestrator_terminator_revert_tag_cloudwatch_event_lambda_permission_name_override" {
  description = "An explicit name to use"
  default = null
}

variable "instance_orchestrator_xogroup_enabled_slashes_cloudwatch_event_lambda_permission_name_override" {
  description = "An explicit name to use"
  default = null
}

variable "instance_orchestrator_xogroup_enabled_colons_cloudwatch_event_lambda_permission_name_override" {
  description = "An explicit name to use"
  default = null
}
