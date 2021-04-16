data "aws_region" "current" {}

resource "aws_lambda_function" "xosphere_event_relay_lambda" {
  s3_bucket = "xosphere-io-releases-${data.aws_region.current.name}"
  s3_key = "event-relay-lambda-${var.xosphere_version}.zip"
  description = "Xosphere Event Relay"
  environment {
    variables = {
      EVENT_ROUTER_SQS_URL = var.event_router_sqs_url
      INSTALLED_REGION: var.installed_region
    }
  }
  function_name = "xosphere-event-relay-lambda"
  handler = "event-relay"
  memory_size = 128
  role = var.event_relay_iam_role_arn
  runtime = "go1.x"
  timeout = 180
  tags = var.tags
  depends_on = [ aws_cloudwatch_log_group.xosphere_event_relay_cloudwatch_log_group ]
}

resource "aws_cloudwatch_log_group" "xosphere_event_relay_cloudwatch_log_group" {
  name = "/aws/lambda/xosphere-event-relay-lambda"
  retention_in_days = 30
}

resource "aws_cloudwatch_event_rule" "xosphere_terminator_revert_tag_cloudwatch_event_rule" {
  name = "xosphere-terminator-revert-tag-change-cloudwatch-rule"
  description = "CloudWatch Event trigger for Terminator on revert tag value change"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.tag"
  ],
  "detail-type": [
    "Tag Change on Resource"
  ],
  "detail": {
    "changed-tag-keys": [
      "xosphere.io/instance-orchestrator/revert"
    ],
    "service": [
      "ec2"
    ],
    "resource-type": [
      "instance"
    ]
  }
}
PATTERN
  is_enabled = true
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "xosphere_terminator_revert_tag_cloudwatch_event_target" {
  arn = aws_lambda_function.xosphere_event_relay_lambda.arn
  rule = aws_cloudwatch_event_rule.xosphere_terminator_revert_tag_cloudwatch_event_rule.name
  target_id = "xosphere-terminator-revert-tag-change-cloudwatch-rule"
}

resource "aws_lambda_permission" "instance_orchestrator_terminator_revert_tag_cloudwatch_event_lambda_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xosphere_event_relay_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.xosphere_terminator_revert_tag_cloudwatch_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "xosphere_terminator_cloudwatch_event_rule" {
  name = "xosphere-terminator-cloudwatch-rule"
  description = "CloudWatch Event trigger for Spot termination notifications for Terminator"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Spot Instance Interruption Warning"
  ]
}
PATTERN
  is_enabled = true
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "xosphere_terminator_cloudwatch_event_target" {
  arn = aws_lambda_function.xosphere_event_relay_lambda.arn
  rule = aws_cloudwatch_event_rule.xosphere_terminator_cloudwatch_event_rule.name
  target_id = "xosphere-terminator-cloudwatch-rule"
}

resource "aws_lambda_permission" "instance_orchestrator_terminator_cloudwatch_event_lambda_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xosphere_event_relay_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.xosphere_terminator_cloudwatch_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "instance_orchestrator_scheduler_tag_change_event_rule" {
  name = "xosphere-scheduler-tag-change-cloudwatch-rule"
  description = "CloudWatch Event trigger for Scheduler on schedule-enabled tag value change"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.tag"
  ],
  "detail-type": [
    "Tag Change on Resource"
  ],
  "detail": {
    "changed-tag-keys": [
      "xosphere.io/instance-orchestrator/schedule-enabled"
    ],
    "service": [
      "ec2"
    ],
    "resource-type": [
      "instance"
    ]
  }
}
PATTERN
  is_enabled = true
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "instance_orchestrator_scheduler_tag_chance_cloudwatch_event_target" {
  arn = aws_lambda_function.xosphere_event_relay_lambda.arn
  rule = aws_cloudwatch_event_rule.instance_orchestrator_scheduler_tag_change_event_rule.name
  target_id = "xosphere-scheduler-enabled-tag-change-cloudwatch-rule"
}

resource "aws_lambda_permission" "instance_orchestrator_scheduler_tag_change_cloudwatch_event_lambda_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xosphere_event_relay_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.instance_orchestrator_scheduler_tag_change_event_rule.arn
  statement_id = "AllowExecutionFromCloudWatch"
}

resource "aws_cloudwatch_event_rule" "instance_orchestrator_xogroup_enabler_cloudwatch_event_rule" {
  name = "xosphere-xogroup-enabler-tag-change-cloudwatch-rule"
  description = "CloudWatch Event trigger for remove xogroup-enabled tag"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.tag"
  ],
  "detail-type": [
    "Tag Change on Resource"
  ],
  "detail": {
    "changed-tag-keys": [
      "xosphere.io/instance-orchestrator/xogroup-name",
      "xosphere.io/instance-orchestrator/xogroup-enabled",
      "xosphere.io/instance-orchestrator/bid-multiplier",
      "xosphere.io/instance-orchestrator/prefer-reserved-instances",
      "xosphere.io/instance-orchestrator/wait-period-in-mins",
      "xosphere.io/instance-orchestrator/enable-burstable",
      "xosphere.io/instance-orchestrator/allowed-instance-types",
      "xosphere.io/instance-orchestrator/min-on-demand",
      "xosphere.io/instance-orchestrator/percent-on-demand",
      "xosphere.io/instance-orchestrator/instance-launch-topic-arn",
      "xosphere.io/instance-orchestrator/instance-launch-error-topic-arn",
      "xosphere.io/instance-orchestrator/instance-terminate-topic-arn",
      "xosphere.io/instance-orchestrator/instance-terminate-error-topic-arn",
      "xosphere.io/instance-orchestrator/alert-topic-arn"
    ],
    "service": [
      "ec2"
    ],
    "resource-type": [
      "instance"
    ]
  }
}
PATTERN
  is_enabled = true
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "instance_orchestrator_xogroup_enabler_cloudwatch_event_target" {
  arn = aws_lambda_function.xosphere_event_relay_lambda.arn
  rule = aws_cloudwatch_event_rule.instance_orchestrator_xogroup_enabler_cloudwatch_event_rule.name
  target_id = "xosphere-xogroup-enabled-tag-change-cloudwatch-rule"
}

resource "aws_lambda_permission" "instance_orchestrator_xogroup_enabler_cloudwatch_event_lambda_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xosphere_event_relay_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.instance_orchestrator_xogroup_enabler_cloudwatch_event_rule.arn
  statement_id = "AllowXogroupEnablerExecutionFromCloudWatch"
}

resource "aws_cloudwatch_event_rule" "instance_orchestrator_group_inspector_tag_change_cloudwatch_event_rule" {
  name = "xosphere-inspector-tag-change-cloudwatch-rule"
  description = "CloudWatch Event trigger for Inspector on xogroup-name and Name tag value change"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.tag"
  ],
  "detail-type": [
    "Tag Change on Resource"
  ],
  "detail": {
    "changed-tag-keys": [
      "Name",
      "xosphere.io/instance-orchestrator/xogroup-name"
    ],
    "service": [
      "ec2"
    ],
    "resource-type": [
      "instance"
    ]
  }
}
PATTERN
  is_enabled = true
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "instance_orchestrator_group_inspector_tag_change_cloudwatch_event_target" {
  arn = aws_lambda_function.xosphere_event_relay_lambda.arn
  rule = aws_cloudwatch_event_rule.instance_orchestrator_group_inspector_tag_change_cloudwatch_event_rule.name
  target_id = "xosphere-group-inspector-tag-change-cloudwatch-rule"
}

resource "aws_lambda_permission" "instance_orchestrator_group_inspector_tag_change_cloudwatch_event_lambda_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xosphere_event_relay_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.instance_orchestrator_group_inspector_tag_change_cloudwatch_event_rule.arn
  statement_id = "AllowGroupInspectorExecutionFromCloudWatch"
}

resource "aws_cloudwatch_event_rule" "instance_orchestrator_group_inspector_ec2_state_change_cloudwatch_event_rule" {
  name = "xosphere-inspector-ec2-state-change-cloudwatch-rule"
  description = "CloudWatch Event trigger for Inspector on EC2 state change"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "pending",
      "terminated"
    ]
  }
}
PATTERN
  is_enabled = true
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "instance_orchestrator_group_inspector_ec2_state_change_cloudwatch_event_target" {
  arn = aws_lambda_function.xosphere_event_relay_lambda.arn
  rule = aws_cloudwatch_event_rule.instance_orchestrator_group_inspector_ec2_state_change_cloudwatch_event_rule.name
  target_id = "xosphere-inspector-ec2-state-change-cloudwatch-rule"
}

resource "aws_lambda_permission" "instance_orchestrator_group_inspector_ec2_state_change_cloudwatch_event_lambda_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xosphere_event_relay_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.instance_orchestrator_group_inspector_ec2_state_change_cloudwatch_event_rule.arn
  statement_id = "AllowGroupInspectorExecutionFromCloudWatchEc2StateChange"
}