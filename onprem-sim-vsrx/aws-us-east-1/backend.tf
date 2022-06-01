terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "qmar-avx-tf-backed-state-2022"
    key    = "prod-rdy/onprem-sim-vsrx/aws-us-east-1/terraform.tfstate"
    region = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "qmar-avx-tf-backed-state-locks"
    encrypt        = true
    profile        = "kumar"
  }
}
