resource "aws_cognito_user_pool" "users" {
  name                     = "cds-snc.ca"
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_domain" "users" {
  domain       = "cds-snc"
  user_pool_id = aws_cognito_user_pool.users.id
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.users.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes              = "profile email openid"
    client_id                     = var.google_client_id
    client_secret                 = var.google_client_secret
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
    token_request_method          = "POST"
    oidc_issuer                   = "https://accounts.google.com"
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = "true"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_user_pool_client" "cognito" {
  name                                 = "client"
  user_pool_id                         = aws_cognito_user_pool.users.id
  supported_identity_providers         = [aws_cognito_identity_provider.google.provider_name]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = ["https://${var.domain}"]
  logout_urls                          = []
  read_attributes                      = []
  write_attributes                     = []
  explicit_auth_flows                  = []
  generate_secret                      = true
}
