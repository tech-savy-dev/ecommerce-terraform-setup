# backend.tf for dev environment
# Bootstrap (run once, already done):
#   aws s3api create-bucket --bucket ecommerce-terraform-state-dev-677450898543 \
#     --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1
#   aws s3api put-bucket-versioning --bucket ecommerce-terraform-state-dev-677450898543 \
#     --versioning-configuration Status=Enabled
#   aws s3api put-bucket-encryption --bucket ecommerce-terraform-state-dev-677450898543 \
#     --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
terraform {
  backend "s3" {
    bucket       = "ecommerce-terraform-state-dev-677450898543"
    key          = "dev/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
