module "notifications" {
  source = "../modules/notifications"

  pipeline_name      = aws_codepipeline.cicd_challenge_pipeline.name
  notification_email = var.notification_email
  alarm_arn          = aws_cloudwatch_metric_alarm.ec2_status_check_failed.arn
}