resource "aws_codebuild_project" "maven_project" {
  name          = var.build_project_name
  description   = "Build Spring Boot JAR and Docker image"
  service_role  = var.service_role_arn
  build_timeout = 10

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_location
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
}
