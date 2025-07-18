output "repository_names" {
  value = local.all_repositories
}

output "repository_urls" {
  value = merge({
    for name, repo in aws_ecr_repository.this :
    name => repo.repository_url
  }, {
    for name in var.ecr_existing :
    name => "imported-${name}" # placeholder, replace if needed
  })
}