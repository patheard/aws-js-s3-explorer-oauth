# AWS JS S3 Explorer + Cognito@Edge

This is an example of how to use [AWS JS S3 Explorer](https://github.com/awslabs/aws-js-s3-explorer/tree/v2-alpha) with [Cognito@Edge](https://github.com/awslabs/cognito-at-edge) and [Google OAuth](https://github.com/jetbrains-infra/terraform-aws-cognito-google-oauth-with-custom-domain).  It does the following:

1. Creates a static website in S3 with a custom domain using CloudFront.
2. Uses Cognito@Edge to authenticate users with Google OAuth before they can access the site.

## Setup
1. Run the devcontainer.
1. Create [Google OAuth client credentials](https://repost.aws/knowledge-center/cognito-google-social-identity-provider).
1. Add a `.tfvars` file with the following variables:
    ```hcl
    domain               = "your-domain.ca"
    google_client_id     = "your-client-id"
    google_client_secret = "your-client-secret"
    ```
1. Run `terraform -chdir=terraform/aws apply`.