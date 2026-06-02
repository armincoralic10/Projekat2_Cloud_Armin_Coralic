resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"
}

resource "null_resource" "s3_bucket" {
  triggers = {
    bucket_name = local.bucket_name
    region      = var.region
  }

  provisioner "local-exec" {
    command = "aws s3 mb s3://${local.bucket_name} --region ${var.region}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rb s3://${self.triggers.bucket_name} --force --region ${self.triggers.region} || true"
  }
}

resource "null_resource" "upload_slike" {
  for_each = fileset(var.slike_lokalni_folder, "*.jpg")

  triggers = {
    bucket_name = local.bucket_name
    file_hash   = filemd5("${var.slike_lokalni_folder}/${each.value}")
  }

  provisioner "local-exec" {
    command = "aws s3 cp ${var.slike_lokalni_folder}/${each.value} s3://${local.bucket_name}/proizvodi/${each.value} --region ${var.region}"
  }

  depends_on = [null_resource.s3_bucket]
}
