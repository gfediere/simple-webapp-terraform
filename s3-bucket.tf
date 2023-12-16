resource "aws_s3_bucket" "tierplatform" {
  bucket = var.s3BucketName
}

resource "aws_s3_bucket_ownership_controls" "tierplatform" {
  bucket = aws_s3_bucket.tierplatform.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "tierplatform" {
  bucket = aws_s3_bucket.tierplatform.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "tierplatform" {
  depends_on = [
    aws_s3_bucket_ownership_controls.tierplatform,
    aws_s3_bucket_public_access_block.tierplatform,
  ]

  bucket = aws_s3_bucket.tierplatform.id
  acl    = "public-read"
}