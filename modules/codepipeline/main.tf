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
        BranchName       = var.branch
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
    # Only include the CodeDeploy deploy stage when the user explicitly
    # provided a CodeDeploy Application name (prevents empty/null config maps)
    for_each = (var.enable_deploy_stage && var.codedeploy_app_name != "") ? [1] : []
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

  # Optional S3 deploy stage for static website pipelines (e.g. React SPA).
  # This is used when a pipeline is intended to deploy to an S3 website bucket
  # instead of using CodeDeploy. It only runs when deploy stage is enabled and
  # a website bucket is provided and CodeDeploy is not configured.
  dynamic "stage" {
    for_each = (var.enable_deploy_stage && var.website_bucket != "" && var.codedeploy_app_name == "") ? [1] : []
    content {
      name = "Deploy"

      action {
        name            = "DeployToS3"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "S3"
        version         = "1"
        input_artifacts = ["build_output"]

        configuration = {
          BucketName = var.website_bucket
          Extract    = "true"
        }
      }
    }
  }
}
