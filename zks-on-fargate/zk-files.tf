# zip zk files
data "archive_file" "zk-s3-codebuild-archive" {
  type = "zip"
  source {
    content = templatefile("zk-files/zk-dockerfile.tmpl", {
      zk_version = var.zk_version
    })
    filename = "Dockerfile"
  }
  source {
    content  = file("zk-files/buildspec.yml")
    filename = "buildspec.yml"
  }
  output_path = "zk-files/zookeeper.zip"
}

# to s3
resource "aws_s3_bucket_object" "zk-s3-codebuild-object" {
  bucket         = aws_s3_bucket.zk-bucket.id
  key            = "zk-files/zookeeper.zip"
  content_base64 = filebase64(data.archive_file.zk-s3-codebuild-archive.output_path)
}
