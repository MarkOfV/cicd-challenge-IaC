# resource "aws_cloudwatch_event_rule" "pipeline_state_change" {
#   name        = "cicd-challenge-pipeline-state-change"
#   description = "Event rule for CodePipeline state changes"
#   event_pattern = jsonencode({
#     "source" = ["aws.codepipeline"],
#     "detail-type" = ["CodePipeline Pipeline Execution State Change"],
#     "detail" = {
#       pipeline = [aws_codepipeline.cicd_challenge_pipeline.name]
#       # SUCCEEDED included here for testing purposes, but would probably remove it in production to avoid excessive notifications.
#       "state" = [
#         "SUCCEEDED",
#         "FAILED"
#       ]
#     }
#   })

#   tags = {
#     Path = "path1"
#   }
# }

# resource "aws_cloudwatch_event_target" "pipeline_state_change_target" {
#   rule        = aws_cloudwatch_event_rule.pipeline_state_change.name
#   target_id   = "send-to-sns"
#   arn         = aws_sns_topic.pipeline_notifications.arn
#   depends_on  = [aws_sns_topic_subscription.pipeline_notifications_email]
# }