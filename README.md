# Projekat 2 — Infrastruktura i Servisi u Oblaku (2025/2026)

Deployment dockerizovane web aplikacije na AWS Cloud koristeći EC2, RDS, S3, ALB i Terraform.

**Autor:** Armin Coralic, FET Tuzla, Telekomunikacije

## Šta projekat radi

Aplikacija "IT Zalihe Cloud" je e-commerce aplikacija za IT opremu sa tri Docker servisa:
- **Frontend** (nginx) — statički HTML/JS koji prikazuje proizvode i korpu
- **Backend** (Python Flask + gunicorn) — REST API za proizvode, korpu i slike
- **Baza** (PostgreSQL) — čuva proizvode i stavke korpe

Na AWS-u je deployovan tako da:
- Frontend i backend rade kao Docker kontejneri na **2 EC2 instance** u dvije AZ
- Baza koristi **Amazon RDS** PostgreSQL u privatnoj mreži
- Slike proizvoda se čuvaju u **S3 bucket-u** i serviraju kroz presigned URL-ove
- **Application Load Balancer** raspoređuje saobraćaj između EC2 instanci

## Arhitektura

Arhitektura i detaljni dijagram u `docs/ARHITEKTURA.md` i `docs/arhitektura.png`.

## Struktura repozitorija

```
Projekat2_AWS/
├── backend/              # Flask aplikacija (app.py, Dockerfile, requirements.txt)
├── frontend/             # nginx + index.html
├── slike/                # 12 slika proizvoda (lokalno; upload-uju se u S3)
├── terraform/            # Terraform kod za automatizovan deployment (DIO 2)
├── docs/                 # Dokumentacija (arhitektura, troškovi, izazovi)
├── docker-compose.yaml   # Production compose (RDS umjesto lokalnog Postgres-a)
├── docker-compose.local.yaml  # Lokalni compose sa Postgres kontejnerom
├── init.sql              # SQL šema + početni podaci
└── README.md             # Ovaj fajl
```

## Preduslovi

- **AWS Academy Sandbox** sa pristupom: VPC, EC2, RDS, S3, ELB
- **Terraform** ≥ 1.5
- **Docker** + **Docker Compose** (za lokalno testiranje)
- **git**
- 12 fajlova `1.jpg` ... `12.jpg` u `slike/` folderu

## Kako pokrenuti — DIO 1: Ručni deployment

Ručni deployment je urađen kroz AWS Management Console i CloudShell (AWS CLI), prateći redoslijed: VPC i subneti → Security Groups → RDS PostgreSQL → S3 bucket sa slikama → 2 EC2 instance sa Docker stack-om → Application Load Balancer. Cijela procedura traje ~10-15 min i prikazana je u video demu. Na kraju se dobije ALB DNS koji se otvara u browseru.

## Kako pokrenuti — DIO 2: Terraform

```bash
# 1. Pokreni Sandbox, kopiraj AWS CLI kredencijale iz "AWS Details"

# 2. U lokalnom terminalu postavi kredencijale
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"
unset AWS_SESSION_TOKEN

# Za EC2 da koristi iste keys (S3 pristup)
export TF_VAR_ec2_aws_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_ec2_aws_secret_key=$AWS_SECRET_ACCESS_KEY

# 3. Pripremi db password
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Otvori terraform.tfvars, postavi db_password

# 4. Init i apply
terraform init
terraform apply
# kucaš "yes"

# Trajanje: ~10 min. Output na kraju ima ALB URL.
```

Detalji u `terraform/README.md`.

## Pristup aplikaciji

Nakon deployment-a:
- `terraform output alb_url` (za Terraform), ili ALB DNS iz EC2 konzole (za ručni deployment)
- Otvori URL u browseru
- Klikni "Spoji se na sistem" — proizvodi se učitavaju sa slikama iz S3

## Brisanje resursa

```bash
# Za Terraform deployment
cd terraform
terraform destroy
# kucaš "yes"

# Za ručni deployment — EndLab dugme u AWS Academy (briše sve resurse Sandbox-a odmah)
```

## Dokumentacija

- `docs/ARHITEKTURA.md` — Detaljan arhitekturni dijagram
- `docs/PROCJENA_TROSKOVA.md` — Mjesečna procjena AWS troškova
- `docs/IZAZOVI.md` — Problemi koji su se javili i kako su riješeni
- `docs/AI_ALATI.md` — Korišteni AI alati i metodologija
- `terraform/README.md` — Detalji o Terraform kodu

## Video demo

Link na video sa pokretanjem sistema, pregledom AWS resursa i high availability demonstracijom:
**https://drive.google.com/file/d/1WMafcEL-Lie6dkhaYBiTb3w9U75yBejK/view**
