data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "web" {
  count = length(aws_subnet.public)

  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name

  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user_data.tftpl", {
    rds_endpoint    = aws_db_instance.main.address
    db_name         = var.db_name
    db_user         = var.db_username
    db_password     = var.db_password
    s3_bucket       = local.bucket_name
    aws_region      = var.region
    aws_access_key  = var.ec2_aws_access_key
    aws_secret_key  = var.ec2_aws_secret_key
    github_repo_url = var.github_repo_url
    run_db_init     = count.index == 0
  })

  depends_on = [
    aws_db_instance.main,
    null_resource.upload_slike,
  ]

  tags = {
    Name = "${var.project_name}-ec2-${count.index + 1}"
  }
}
