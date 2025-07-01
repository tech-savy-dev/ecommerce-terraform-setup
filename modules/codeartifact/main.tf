resource "aws_codeartifact_repository" "this" {
  domain     = var.domain_name
  repository = var.repository_name

  dynamic "upstream" {
    for_each = var.upstream_repositories
    content {
      repository_name = upstream.value
    }
  }

  dynamic "external_connections" {
    for_each = var.external_connections != null ? var.external_connections : []
    content {
      external_connection_name = external_connections.value
    }
  }
}

