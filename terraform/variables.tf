variable "region" {
  description = "AWS region u kojem se kreira infrastruktura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Naziv projekta — koristi se kao prefix u imenima resursa"
  type        = string
  default     = "projekat2"
}

variable "vpc_cidr" {
  description = "CIDR blok za VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Lista CIDR blokova za public subnete (po jedan za svaku AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Lista CIDR blokova za private subnete (po jedan za svaku AZ)"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

variable "availability_zones" {
  description = "Lista Availability Zones u koje se raspoređuju subneti"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_name" {
  description = "Ime PostgreSQL baze koja se kreira pri pokretanju RDS-a"
  type        = string
  default     = "prodavnica"
}

variable "db_username" {
  description = "Master korisničko ime za RDS"
  type        = string
  default     = "korisnik"
}

variable "db_password" {
  description = "Master lozinka za RDS (postavlja se preko terraform.tfvars)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class (db.t3.micro je Free Tier)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Veličina RDS storage-a u GB"
  type        = number
  default     = 20
}

variable "ec2_instance_type" {
  description = "EC2 instance tip (t2.micro je Free Tier)"
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_name" {
  description = "Ime SSH ključa za EC2 (vockey u AWS Academy Sandbox-u)"
  type        = string
  default     = "vockey"
}

variable "ec2_iam_instance_profile" {
  description = "IAM instance profile naziv (LabInstanceProfile u Sandbox-u). Trenutno se ne koristi jer Cloud Ops Sandbox blokira PassRole."
  type        = string
  default     = "LabInstanceProfile"
}

variable "ec2_aws_access_key" {
  description = "AWS Access Key koji EC2 koristi za S3 pristup (umjesto IAM role-a, zbog Cloud Ops Sandbox ogranicenja). Postavi sa: export TF_VAR_ec2_aws_access_key=$AWS_ACCESS_KEY_ID"
  type        = string
  sensitive   = true
}

variable "ec2_aws_secret_key" {
  description = "AWS Secret Key koji EC2 koristi za S3 pristup. Postavi sa: export TF_VAR_ec2_aws_secret_key=$AWS_SECRET_ACCESS_KEY"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "URL GitHub repozitorija sa aplikacijom (klonira se na EC2 prilikom pokretanja)"
  type        = string
  default     = "https://github.com/armincoralic10/Projekat2_Cloud_Armin_Coralic.git"
}

variable "s3_bucket_prefix" {
  description = "Prefix za S3 bucket — sufiks se generiše random-om jer bucket imena moraju biti globalno jedinstvena"
  type        = string
  default     = "projekat2-armin-slike"
}

variable "slike_lokalni_folder" {
  description = "Lokalni folder sa slikama proizvoda (relativan na terraform folder)"
  type        = string
  default     = "../slike"
}
