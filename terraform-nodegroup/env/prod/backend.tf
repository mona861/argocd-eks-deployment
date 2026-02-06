// Configuring S3 and DDB for state storage and lock
terraform {
  backend "s3" {
    profile      = "demo"
    encrypt      = true
    bucket       = "tf-state-us-east-1-demo"
    use_lockfile = true # Enable S3 native locking
    region       = "us-east-1"
    key          = "tf/state/argo-blue-green-deployment/stack/prod/terraform.tfstate"
  }
}
