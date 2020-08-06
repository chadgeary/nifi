# s3 bucket
resource "aws_s3_bucket" "tf-nifi-bucket" {
  bucket                  = var.bucket_name
  acl                     = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.tf-nifi-kmscmk-s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# s3 block all public access to bucket
resource "aws_s3_bucket_public_access_block" "tf-nifi-bucket-pubaccessblock" {
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# s3 objects (zookeeper playbook)
resource "aws_s3_bucket_object" "tf-nifi-zookeepers" {
  for_each                = fileset("zookeepers/", "*")
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  key                     = "zookeepers/${each.value}"
  source                  = "zookeepers/${each.value}"
  etag                    = filemd5("zookeepers/${each.value}")
}

# s3 objects (nodes playbook)
resource "aws_s3_bucket_object" "tf-nifi-nodes" {
  for_each                = fileset("nodes/", "*")
  bucket                  = aws_s3_bucket.tf-nifi-bucket.id
  key                     = "nodes/${each.value}"
  source                  = "nodes/${each.value}"
  etag                    = filemd5("nodes/${each.value}")
}
