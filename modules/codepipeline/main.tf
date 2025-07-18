resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline_name
  role_arn = var.service_role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.repo_owner}/${var.repo_name}"
        BranchName       = "main"
        DetectChanges    = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "CodeBuild_Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.build_project_name
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_deploy_stage ? [1] : []
    content {
      name = "Deploy"

      action {
        name            = "DeployToECS"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeploy"
        version         = "1"
        input_artifacts = ["build_output"]

        configuration = {
          ApplicationName     = var.codedeploy_app_name
          DeploymentGroupName = var.codedeploy_group_name
        }
      }
    }
  }
}
