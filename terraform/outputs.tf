output "alb_url" {
  description = "Javna URL adresa aplikacije (otvori u browseru)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "alb_dns_name" {
  description = "DNS ime ALB-a"
  value       = aws_lb.main.dns_name
}

output "s3_bucket_name" {
  description = "Ime S3 bucket-a sa slikama proizvoda"
  value       = local.bucket_name
}

output "rds_endpoint" {
  description = "RDS endpoint (host:port) — koristi se u .env na EC2 instancama"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "ID kreirane VPC mreže"
  value       = aws_vpc.main.id
}

output "ec2_instance_ids" {
  description = "ID-jevi obje EC2 instance"
  value       = aws_instance.web[*].id
}

output "ec2_public_ips" {
  description = "Javni IP-jevi EC2 instanci (za SSH/debug)"
  value       = aws_instance.web[*].public_ip
}
