provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "gclauar-terraform-state"
    key          = "spotify_pipeline/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

# --------- BUCKETS S3 ---------

resource "aws_s3_bucket" "sptfy_bronze" {
  bucket = "${var.base_bucket_name}-bronze-${var.user_tag}"
  tags   = { Ambiente = "Spotify-pipeline", Camada = "Bronze" }
}

resource "aws_s3_bucket" "sptfy_silver" {
  bucket = "${var.base_bucket_name}-silver-${var.user_tag}"
  tags   = { Ambiente = "Spotify-pipeline", Camada = "Silver" }
}

resource "aws_s3_bucket" "sptfy_gold" {
  bucket = "${var.base_bucket_name}-gold-${var.user_tag}"
  tags   = { Ambiente = "Spotify-pipeline", Camada = "Gold" }
}

locals {
  buckets = {
    bronze = aws_s3_bucket.sptfy_bronze.id
    silver = aws_s3_bucket.sptfy_silver.id
    gold   = aws_s3_bucket.sptfy_gold.id
  }
}

resource "aws_s3_bucket_public_access_block" "lake" {
  for_each                = local.buckets
  bucket                  = each.value
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "lake" {
  for_each = { for k, v in local.buckets : k => v if k == "bronze" }
  bucket   = each.value
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lake" {
  for_each = local.buckets
  bucket   = each.value
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

# --------- DATABASES GLUE ---------

resource "aws_glue_catalog_database" "sptfy_db_bronze" {
  name        = "db_sptfy_bronze"
  description = "Database para as tabelas Bronze do Lakehouse com dados do Spotify"
}

resource "aws_glue_catalog_database" "sptfy_db_silver" {
  name        = "db_sptfy_silver"
  description = "Database para as tabelas Silver do Lakehouse com dados do Spotify"
}

resource "aws_glue_catalog_database" "sptfy_db_gold" {
  name        = "db_sptfy_gold"
  description = "Database para as tabelas Gold do Lakehouse com dados do Spotify"
}

# --------- LAMBDA ---------

# --------- EC2 ---------