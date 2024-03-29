

resource "aws_s3_bucket" "bucket" {
  bucket              = "tera-hash"
  force_destroy       = "true"
  object_lock_enabled = "false"


  tags = {
    Name        = "tera-hash"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "control" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.control,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}


# Upload object into the bucket

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.bucket.id
  key = "index.html"
  source     = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.bucket.id
  key = "error.html"
  source     = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "show" {
  bucket = aws_s3_bucket.bucket.id
  key = "show.png"
  source = "show.png"
  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.example ]
}