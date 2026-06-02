# Procjena AWS troškova

Procjena za **us-east-1** region, on-demand cijene (maj 2026).

## Mjesečni troškovi

| Servis | Specifikacija | Cijena/mjesec |
|---|---|---|
| EC2 (2× t2.micro) | 2 × $0.0116/h × 720h | $16.70 |
| RDS PostgreSQL | db.t3.micro, $0.017/h × 720h | $12.24 |
| RDS Storage | 20 GB gp2 | $2.30 |
| EBS (2× root volumes) | 2 × 8 GB gp2 | $1.60 |
| Application Load Balancer | $0.0225/h × 720h + LCU | ~$17 |
| S3 | <1 GB storage, mali broj zahtjeva | <$0.10 |
| Data Transfer Out | <10 GB/mjesec očekivano | <$1 |
| **UKUPNO** | | **~$51/mjesec** |

## Napomena za AWS Academy Sandbox

Sandbox budget je **$100 ukupno** (ne mjesečno). Trošak za naš projekat dok rade resursi je **~$1.50/dan**. Za par dana testiranja $5-10, dovoljno unutar budgeta.

Resurse je moguće brzo obrisati i ponovo kreirati Terraform-om (`terraform destroy` / `terraform apply`), pa ne moraju raditi non-stop između sesija rada.

## Izvor cijena

[AWS Pricing Calculator](https://calculator.aws/) za interaktivnu procjenu.
