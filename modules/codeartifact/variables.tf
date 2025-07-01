variable "domain_name" {
  type        = string
  description = "CodeArtifact domain name"
}

variable "repository_name" {
  type        = string
  description = "CodeArtifact repository name"
}

variable "upstream_repositories" {
  type        = list(string)
  default     = []
  description = "List of internal upstream CodeArtifact repositories"
}

variable "external_connections" {
  type        = list(string)
  default     = []
  description = "List of external connections like public:maven-central"
}

