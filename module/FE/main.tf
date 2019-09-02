provider "aws" {
  region = var.region
}

module "aws_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.bucketname
  acl    = "private"
  tags = {
    Owner       = var.namespace
    Environment = var.environment
  }

  # website_inputs = [
  #   {
  #     index_document           = "index.html"
  #     error_document           = "error.html"
  #     redirect_all_requests_to = null
  #     routing_rules            = <<EOF
  #   [{
  #   "Condition": {
  #       "KeyPrefixEquals": "docs/"
  #   },
  #   "Redirect": {
  #       "ReplaceKeyPrefixWith": "documents/"
  #   } 
  #   }]
  #   EOF
  #   }
  # ]


}

