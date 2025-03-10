resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "tf-nodejs-bucket02"
  tags = {
    Name        = "sas_nodejs_bucket"
    Environment = "Dev"
  }
}
# resource "aws_s3_object" "tf_s3_object" {
#   bucket = aws_s3_bucket.tf_s3_bucket.bucket
#   for_each = fileset("../public/images", "**")
#   key    = "images/${each.key}"
#   source = "../public/images/${each.key}"
# }
resource "aws_s3_object" "tf_s3_object" {
  bucket = aws_s3_bucket.tf_s3_bucket.bucket
  for_each = fileset("nodejs-mysql/public/images", "**")
  key    = "images/${each.key}"
  source = "nodejs-mysql/public/images/${each.key}"
}

 output "bucket_name" {
     value = aws_s3_bucket.tf_s3_bucket.bucket
   }

output "bucket_arn" {
     value = aws_s3_bucket.tf_s3_bucket.arn
   }