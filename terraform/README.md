# Terraform - automatizovan deployment Projekta 2

Ovaj folder sadrži Terraform konfiguraciju koja kreira **identičnu infrastrukturu** kao
ručni deployment iz DIO 1, samo automatski jednom komandom.

## Šta se kreira

- VPC sa 4 subneta (2 public, 2 private) u 2 Availability Zone
- Internet Gateway + Route tables
- 3 Security Groups (ALB → EC2 → RDS, princip least privilege)
- RDS PostgreSQL `db.t3.micro` u privatnoj mreži
- S3 bucket + upload 12 slika proizvoda iz `../slike/`
- 2 EC2 instance (t2.micro) sa Docker stack-om u 2 AZ
- Application Load Balancer sa Target Group i Listener-om

## Preduslovi

- **Terraform** ≥ 1.5 (`terraform version`)
- **AWS CLI** konfigurisan sa AWS Academy Sandbox kredencijalima
- Lokalni folder `../slike/` sa 12 fajlova `1.jpg` ... `12.jpg`
- Aktivna AWS Academy Sandbox sesija sa pristupom: VPC, EC2, RDS, S3, ELB, IAM (read)

## Konfiguracija kredencijala

Sandbox kredencijali se mijenjaju svaki put kad se restartuje sesija.
Uzmi ih iz **AWS Details** linka u Academy tabu i postavi u environment:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

Provjera da radi:
```bash
aws sts get-caller-identity
```

## Pokretanje

```bash
# 1. Kopiraj template za varijable i postavi password
cp terraform.tfvars.example terraform.tfvars
# Otvori terraform.tfvars i postavi db_password

# 2. Inicijalizacija (skida AWS provider)
terraform init

# 3. Pregled šta će se napraviti
terraform plan

# 4. Pokretanje (~10 min, najviše čeka RDS)
terraform apply
# Otkucaj "yes" kad pita za potvrdu

# Na kraju ispiše:
#   alb_url = "http://projekat2-alb-XXX.us-east-1.elb.amazonaws.com"
#   s3_bucket_name = "projekat2-armin-slike-XXX"
#   ...
```

Otvori `alb_url` u browseru — kliknieš "Spoji se na sistem", aplikacija radi.

## Brisanje svih resursa

```bash
terraform destroy
```

Otkucaj "yes". Briše VPC, RDS, S3 (sa slikama), EC2, ALB — sve što je `apply` kreirao.

## Struktura fajlova

| Fajl | Sadržaj |
|---|---|
| `versions.tf` | Verzije Terraform-a i AWS provider-a |
| `provider.tf` | AWS provider konfiguracija + default tagovi |
| `variables.tf` | Sve konfigurabilne vrijednosti (region, CIDR-ovi, DB, EC2...) |
| `networking.tf` | VPC, subneti, IGW, route tables |
| `security.tf` | 3 Security Groups |
| `database.tf` | DB Subnet Group + RDS PostgreSQL |
| `storage.tf` | S3 bucket + upload 12 slika |
| `compute.tf` | AMI lookup + 2 EC2 instance |
| `user_data.tftpl` | Bash skripta koja se izvršava pri pokretanju EC2 |
| `loadbalancer.tf` | ALB + Target Group + Listener |
| `outputs.tf` | Ispisane vrijednosti nakon apply-a |
| `terraform.tfvars.example` | Template za stvarni `terraform.tfvars` (NE ide u git) |
