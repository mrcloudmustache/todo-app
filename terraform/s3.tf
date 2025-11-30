// Configure the S3 bucket to store the application source bundle
resource "aws_s3_bucket" "source_bundle" {
  bucket = "${var.app_name}-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.app_name}-bucket-${random_id.bucket_suffix.hex}"
    Environment = var.environment
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

// Upload the application source bundle to S3
resource "aws_s3_object" "source_bundle_zip" {
  bucket = aws_s3_bucket.source_bundle.id
  key    = "beanstalk/source_bundle.zip"
  source = "../source_bundle.zip"
}