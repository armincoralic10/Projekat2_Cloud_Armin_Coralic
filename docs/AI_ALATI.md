# Korišteni AI alati i metodologija

## Korišteni alat

**Claude** — kao asistent tokom razvoja projekta.

## Metodologija rada

Pristup koristenju AI-ja nije bio "generisi cijeli projekat jednim prompt-om" (sto specifikacija eksplicitno zabranjuje). Umjesto toga, koristio sam ga kao:

1. **Mentor i sparing partner** — pitanja o AWS servisima, najboljim praksama, razlozi iza odluka
2. **Razumijevanje i ispravljanje koda** — Terraform sintaksa, Docker konfiguracije, bash skripte
3. **Debugger** — kod problema (Sandbox UI bug, IAM PassRole, S3 ObjectLock) analiza grešaka i trazenje rjesenja

Sav generisani kod sam **pregledao i razumio** prije nego što je commitovan.

---

## Lista promptova po fazama (hronološki)

1. "Moram da uradim projekat iz clouda ciji su zahtjevi:
• Frontend i backend: pokrenuti kao Docker kontejneri na EC2
instanci/instancama
• Backend mora biti pokrenut na najmanje 2 EC2 instance radi demonstracije
visoke dostupnosti
• Baza podataka: koristiti Amazon RDS (PostgreSQL ili MySQL)
• S3 Storage: koristiti S3 za statičke asset-e, frontend hosting ili media datoteke
• Load balancing: koristiti Application Load Balancer (ALB)
• Security Groups: pravilno konfigurisana kontrola pristupa između servisa
• Aplikacija mora biti dostupna putem javne URL adrese (ALB DNS name).
- Treba da postavim svoju aplikaciju rucnim deploymentom u aws sandbox okruzenju, a nakon toga i da naparvim terraform skripte, da li mi mozes pomoci kako da to uradim ?"

### Faza 2 — Prilagodba aplikacije za AWS

2. Pregled koda aplikacije sa prvog projekta od strane Claude-a, izmjene u: backend/app.py (boto3, presigned URL endpoint, /api/health), backend/requirements.txt (boto3, gunicorn), backend/Dockerfile (gunicorn), init.sql (slika_kljuc kolona), frontend/index.html (relativni URL-ovi, prikaz slika), frontend/nginx.conf (proxy), docker-compose.yaml (production verzija)

### Faza 3 — Ručni deployment na AWS (DIO 1)

3. Sandbox vodič — pristup Academy portalu, Cloud Operations kurs, "Sandbox Environment" modul
4. "Iz nekog razloga ne mogu ništa da izaberem za instance type" (RDS UI bug)
5. "Nema ni MySQL instance type"
6. Prelazak na CloudShell + AWS CLI za kreiranje RDS-a
7. Kreiranje ALB-a, Target Group-a, Listener-a, attachment-a

### Faza 4 — Video demo

8. "Daj mi skriptu za tihi video sa tekstualnim naslovima unutar videa"

### Faza 5 — Sandbox briše resurse pri isteku sesije

9. "Sesija od 3h mi je istekla i sada nemam ni EC2 instanci ni RDS db" (Sandbox je sve obrisao) — motivacija za prelazak na Terraform automatizaciju

### Faza 6 — Terraform (DIO 2)

10. Objasni mi detaljno kako da napravim terraform skripte i nacin na koji terraform funkcionise i kakva struktura terraform fajlova treba da bude
11. Debugging Terraform error-a:
    - S3 ObjectLockConfiguration AccessDenied → workaround sa null_resource + local-exec
    - IAM PassRole zabranjen → uklanjanje iam_instance_profile + AWS keys u .env
    - EC2 gp3 volume blokiran → eksplicitno gp2 u root_block_device

### Faza 7 — Dokumentacija (DIO 3)

12. Pomozi mi da napisem dokumentaciju za projekat, napravi mi template za dokmumentaciju u koje ja mogu unijeti svoje detalje o konfiguraciji citavog projekta
13. Kako bi bilo najbolje da podijelim dokumentaciju, da li da stavljam sve u jedan dokument ili da ih napravim vise?
14. Kako da izracunam troskove?

---

## Šta je AI ispravio

- Izmjene u backend/app.py (S3 endpoint, /api/health)
- Izmjene u frontend/index.html (relativni URL-ovi, prikaz slika)
- frontend/nginx.conf (proxy konfiguracija)


