#
# Upload bucket for Fable videos
#
module "s3_fable" {
  source = "github.com/cds-snc/terraform-modules//S3?ref=v9.2.1"

  billing_tag_value = "s3-explorer"
  bucket_name       = "fable-videos-cds-snc"

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = module.s3_fable.s3_bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["HEAD", "GET", "POST", "PUT", "DELETE"]
    allowed_origins = [
      "https://s3.amazonaws.com",
      "https://s3.${var.region}.amazonaws.com",
      "https://s3-explorer.cdssandbox.xyz"
    ]
    expose_headers = [
      "ETag",
      "x-amz-meta-custom-header",
      "x-amz-server-side-encryption",
      "x-amz-request-id",
      "x-amz-id-2",
      "date"
    ]
    max_age_seconds = 3000
  }
}
