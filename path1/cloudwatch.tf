resource "aws_cloudwatch_log_group" "codebuild_log_group" {
  name              = "/aws/codebuild/cicd-challenge-build"
  retention_in_days = 14

  tags = {
    Path = "path1"
  }
}

#CloudWatch alarm for EC2 status check

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  alarm_name          = "cicd-challenge-ec2-status-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    InstanceId = aws_instance.app.id
  }

  alarm_description = "This metric monitors EC2 instance status check failures."
  alarm_actions     = [aws_sns_topic.pipeline_notifications.arn]
  ok_actions        = [aws_sns_topic.pipeline_notifications.arn]

  tags = {
    Path = "path1"
  }
}