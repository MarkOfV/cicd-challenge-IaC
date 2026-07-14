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