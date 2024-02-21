#
# Website
#
module "website" {
  source = "github.com/cds-snc/terraform-modules//simple_static_website?ref=v9.2.3"

  domain_name_source = var.domain
  s3_bucket_name     = "s3-explorer-cdssandbox-xyz"  
  billing_tag_value  = "s3-explorer"

  lambda_function_association = [{
    event_type   = "viewer-request"
    include_body = false
    lambda_arn   = aws_lambda_function.cognito_at_edge.qualified_arn
  }]

  providers = {
    aws           = aws
    aws.dns       = aws
    aws.us-east-1 = aws.us-east-1
  }
}

module "website_files" {
  source   = "hashicorp/dir/template"
  base_dir = "${path.module}/s3-explorer"
}

resource "aws_s3_object" "website_files" {
  for_each = module.website_files.files

  bucket       = module.website.s3_bucket_id
  key          = each.key
  source       = each.value.source_path
  etag         = each.value.digests.md5
  content_type = each.value.content_type
}
