terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }

}

provider "aws" {
  region = "us-east-1"
}


resource "random_id" "rand_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "donatewebpage-bucket" {
  bucket = "donate-static-bucket-${random_id.rand_id.hex}"
}


resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.donatewebpage-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "mywebapp" {
  bucket = aws_s3_bucket.donatewebpage-bucket.id

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid       = "PublicReadGetObject",
          Effect    = "Allow",
          Principal = "*",
          Action    = "s3:GetObject",
          Resource  = "arn:aws:s3:::${aws_s3_bucket.donatewebpage-bucket.id}/*"

        }
      ]
    }
  )
}


resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.donatewebpage-bucket.bucket
  source = "./index.html"
  key    = "./index.html"

}
resource "aws_s3_object" "style_css" {
  bucket = aws_s3_bucket.donatewebpage-bucket.bucket
  source = "./style.css"
  key    = "./style.css"
}
