resource "aws_sns_topic" "pipeline_notifications" {
  name = "cicd-challenge-pipeline-notifications"

  tags = {
    Path = "path1"
  }
}

resource "aws_sns_topic_subscription" "pipeline_notifications_email" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}


data "aws_iam_policy_document" "pipeline_notification_policy" {
  statement {
    sid       = "AllowEventBridgeToPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.pipeline_notifications.arn]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.pipeline_state_change.arn]
    }
  }

   statement {
    sid       = "AllowCloudWatchAlarmToPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.pipeline_notifications.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_metric_alarm.ec2_status_check_failed.arn]
    }
  }
}

resource "aws_sns_topic_policy" "pipeline_notification_policy" {
  arn = aws_sns_topic.pipeline_notifications.arn
  policy = data.aws_iam_policy_document.pipeline_notification_policy.json
}