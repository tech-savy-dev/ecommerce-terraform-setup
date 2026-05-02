variable "domain_name" {
  description = "Primary domain name for the ACM certificate (e.g. example.com)"
  type        = string
  default     = "example.com"
}

variable "san_names" {
  description = "Subject Alternative Names for the certificate (e.g. [\"www.example.com\"])"
  type        = list(string)
  default     = ["www.example.com"]
}
