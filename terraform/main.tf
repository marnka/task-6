provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"
  s3_host    = "http://localhost:4566"
  lambda_host = "http://localhost:4566"
}

resource "aws_s3_bucket" "s3_start" {
  bucket = "s3-start"
}

resource "aws_s3_bucket" "s3_finish" {
  bucket = "s3-finish"
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.s3_start.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_lambda_function" "copy_file" {
  filename      = "lambda.zip"
  function_name = "copyFileFunction"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = "arn:aws:iam::000000000000:role/lambda-role"

  environment {
    variables = {
      SOURCE_BUCKET = aws_s3_bucket.s3_start.bucket
      DEST_BUCKET   = aws_s3_bucket.s3_finish.bucket
    }
  }
}

resource "aws_s3_bucket_notification" "s3_start_notification" {
  bucket = aws_s3_bucket.s3_start.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.copy_file.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
