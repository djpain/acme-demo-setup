# Configure the AWS Provider
provider "aws" {
  region = var.region
}

module "acme-website" {
  source  = "freakazoid633/static-website/aws"

  profile     = "default"
  region      = "ap-southeast-2"
  bucket_name = "acme-bucket-${environment}"
  cname       = ["*.acme.com"]
  domain      = "acme.com"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  logging {
    log-bucket        = "my-super-duper-website-logs"
    log-bucket-prefix = "static-website-logs"

  }
}

# module "aws_s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"
#   bucket = var.bucketname
#   acl    = "private"
#   tags = {
#     Owner       = var.namespace
#     Environment = var.environment
#   }

#   website_inputs = [
#     {
#       index_document           = "index.html"
#       error_document           = "error.html"
#       redirect_all_requests_to = null
#       routing_rules            = <<EOF
#     [{
#     "Condition": {
#         "KeyPrefixEquals": "docs/"
#     },
#     "Redirect": {
#         "ReplaceKeyPrefixWith": "documents/"
#     } 
#     }]
#     EOF
#     }
#   ]


# }

