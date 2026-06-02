# Arhitektura sistema

## Komponente

- **VPC** (10.0.0.0/16) — 2 public subneta za EC2/ALB, 2 private subneta za RDS, u 2 AZ
- **2x EC2** (t2.micro) — Docker stack sa nginx-om i Flask backend-om
- **RDS PostgreSQL** (db.t3.micro) — u privatnoj mreži, baza `prodavnica`
- **S3 bucket** — 12 slika proizvoda, pristup preko presigned URL-ova iz backend-a
- **ALB** — internet-facing, raspoređuje saobraćaj između 2 EC2 sa health check-om na `/api/health`
- **3 Security Groups** (least privilege): ALB → EC2 → RDS, svaki sloj dopušta samo prethodni
