# Izazovi tokom deployment-a i rješenja

Tokom rada na projektu naišlo se na nekoliko realnih problema specifičnih za AWS Academy Sandbox okruženje. Svaki problem je dokumentovan ovdje sa rješenjem, jer ne dolaze iz "standardnih" AWS tutorijala.

---

## 1. AWS Console UI bug — Instance type prazan kod kreiranja RDS-a

**Problem:** Pri kreiranju RDS instance kroz AWS konzolu, padajući meni "Instance type" je ostao prazan iako je izabran Free Tier template. Sve t-klase su bile zasivljene. Pokušaj kreiranja vratio je "This field is required".

**Uzrok:** Vjerovatno cache problem konzole ili nekonzistentno stanje Free Tier template-a u Sandbox sesiji. Engine version je ostao na verziji sa "-R1" sufiksom (Multi-AZ DB cluster verzija) koja ne podržava t-klase.

**Rješenje:** Prelaz na AWS CloudShell + AWS CLI:
```bash
aws rds create-db-instance \
  --db-instance-identifier projekat2-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username korisnik \
  --master-user-password "..." \
  --allocated-storage 20 \
  --db-name prodavnica \
  --vpc-security-group-ids $RDS_SG \
  --db-subnet-group-name projekat2-db-subnet-group \
  --no-publicly-accessible
```

CLI zaobilazi UI ograničenja jer ide direktno na API. Ovo je standardna praksa za AWS — CLI je često stabilniji od UI-ja.

---

## 2. Sandbox briše sve resurse preko noći

**Problem:** Sutradan ujutro, svi EC2, RDS, ALB, S3, VPC i SG resursi su nestali — kao da Sandbox nikad nije pokrenut.

**Uzrok:** AWS Academy Sandbox ima automatski cleanup koji briše "skupe" resurse nakon perioda neaktivnosti (varira po instituciji).

**Rješenje (i razlog za DIO 2 — Terraform):** Umjesto da svaki put 2-3h ručno klikam kroz AWS konzolu da rekreiram sve, **Infrastructure as Code** rješava problem:
```bash
terraform apply  # ~10 min, cijela infrastruktura nazad
```

---

## 3. AWS Academy Cloud Operations vs Learner Lab

**Problem:** Imao sam pristup "AWS Academy Cloud Operations" kursu, a ne klasičnom "Learner Lab"-u. Razlika nije bila očigledna.

**Razlika:**
- **Learner Lab** (običan) — koristi `voclabs` IAM role sa širokim dozvolama, predefinisani `LabInstanceProfile` za EC2, `vockey` SSH ključ, CloudShell radi automatski sa role-om
- **Cloud Operations Sandbox** — koristi `awsstudent` IAM **user** (ne role) sa restriktivnijom polisom (`lab_policy`), bez predefinisanog SSH ključa, Bastion Host arhitektura

**Posljedice koje smo morali fixovati:**
- `awsstudent` ne može `iam:PassRole` → EC2 ne može imati IAM instance profile → S3 pristup ide kroz AWS keys u `.env`
- `awsstudent` ne može `s3:GetBucketObjectLockConfiguration` → Terraform `aws_s3_bucket` resurs ne radi (vidi izazov #5)
- Nema `vockey` po defaultu → bilo bi potrebno kreirati novi key pair

**Rješenje:** Sve workarounds dokumentovani u Terraform kodu sa komentarima. Cloud Ops Sandbox traži više truda ali daje realniji utisak rada sa ograničenim IAM polisama (kao što je i u stvarnim firmama).

---

## 4. S3 ObjectLockConfiguration AccessDenied

**Problem:**
```
Error: reading S3 Bucket object lock configuration: 
StatusCode: 403, api error AccessDenied:
not authorized to perform: s3:GetBucketObjectLockConfiguration
```

**Uzrok:** Terraform AWS provider 5.x **uvijek** poziva `GetBucketObjectLockConfiguration` API tokom refresh-a `aws_s3_bucket` resursa, čak i ako Object Lock nije konfigurisan. Sandbox `lab_policy` to eksplicitno blokira.

**Rješenje:** Zaobići `aws_s3_bucket` resurs i koristiti AWS CLI direktno kroz `null_resource + local-exec`:

```hcl
resource "null_resource" "s3_bucket" {
  triggers = { bucket_name = local.bucket_name }
  
  provisioner "local-exec" {
    command = "aws s3 mb s3://${local.bucket_name} --region ${var.region}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rb s3://${self.triggers.bucket_name} --force"
  }
}
```

Bucket je i dalje upravljan kroz Terraform lifecycle (create + destroy), samo se zaobilazi AWS provider read funkcija koja poziva problematičan API.

---

## 5. EC2 ne može koristiti gp3 volume tip

**Problem:**
```
UnauthorizedOperation: not authorized to perform: ec2:RunInstances 
on resource: ...volume/*
```

**Uzrok:** Default volume tip u AWS provider 5.x je `gp3`. Sandbox `lab_policy` blokira kreiranje `gp3` volumes (vjerovatno samo `gp2` je dozvoljen).

**Rješenje:** Eksplicitno postaviti `gp2`:
```hcl
resource "aws_instance" "web" {
  ...
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
}
```

---

## 6. Race condition pri inicijalizaciji baze

**Problem:** Obje EC2 instance startuju paralelno i obje pokušaju da pokrenu `init.sql` na praznu RDS bazu — duplikati podataka, eventualne SQL greške.

**Rješenje:** Samo prva instanca (`count.index == 0`) pokreće inicijalizaciju, sa provjerom:

```bash
# Iz user_data.tftpl:
%{ if run_db_init }
sleep 10
COUNT=$(PGPASSWORD="${db_password}" psql -h ${rds_endpoint} -U ${db_user} -d ${db_name} \
  -t -c "SELECT COUNT(*) FROM racunari" 2>/dev/null | tr -d ' \n' || echo 0)
if [ -z "$COUNT" ] || [ "$COUNT" = "0" ]; then
  PGPASSWORD="${db_password}" psql -h ${rds_endpoint} -U ${db_user} -d ${db_name} -f init.sql
fi
%{ endif }
```

Druga prednost: ako pokrenem `terraform apply` više puta, init se izvrši samo jednom.

---

## 7. Hardkodovan localhost:5000 u frontend-u

**Problem:** Originalni frontend (`index.html` iz Projekta 1) je imao `fetch('http://localhost:5000/api/...')` što radi lokalno ali ne radi kroz ALB.

**Rješenje:** Frontend koristi relativne URL-ove (`/api/...`), a nginx unutar frontend kontejnera proxy-uje `/api/*` na backend kontejner:

```nginx
# frontend/nginx.conf
location /api/ {
    proxy_pass http://backend:5000;
}
```

Ovo je standardna mikroservisna arhitektura — frontend ne mora znati gdje je backend, sve ide kroz isti origin (zaobilazi i CORS problem).

---

## 8. Hot-reload volumes u docker-compose nisu za AWS

**Problem:** Originalni `docker-compose.yaml` je imao bind mount-e za hot reload tokom razvoja (`./backend:/app`), što ne radi u produkciji na EC2.

**Rješenje:** Dvije verzije compose fajlova:
- `docker-compose.yaml` — production (bez bind mounts, bez lokalnog DB kontejnera, koristi env varijable za RDS)
- `docker-compose.local.yaml` — lokalni razvoj (sa Postgres kontejnerom za testiranje bez AWS-a)
