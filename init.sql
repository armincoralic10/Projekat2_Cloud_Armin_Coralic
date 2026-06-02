CREATE TABLE IF NOT EXISTS racunari (
    id SERIAL PRIMARY KEY,
    naziv VARCHAR(100) NOT NULL,
    kategorija VARCHAR(50) NOT NULL,
    cijena NUMERIC(10, 2) NOT NULL,
    slika_kljuc VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS korpa (
    id SERIAL PRIMARY KEY,
    proizvod_id INTEGER REFERENCES racunari(id) ON DELETE CASCADE,
    kolicina INTEGER DEFAULT 1
);


INSERT INTO racunari (naziv, kategorija, cijena, slika_kljuc) VALUES
    ('ThinkPad T14', 'Laptop', 2100.00, 'proizvodi/1.jpg'),
    ('Nvidia RTX 4070', 'Komponenta', 1350.00, 'proizvodi/2.jpg'),
    ('Logitech MX Master 3S', 'Oprema', 220.00, 'proizvodi/3.jpg'),
    ('MacBook Pro 16 M3', 'Laptop', 5200.00, 'proizvodi/4.jpg'),
    ('Dell UltraSharp 27"', 'Monitor / Oprema', 850.00, 'proizvodi/5.jpg'),
    ('AMD Ryzen 7 7800X3D', 'Komponenta', 750.00, 'proizvodi/6.jpg'),
    ('Corsair K70 RGB', 'Mehanička tastatura', 300.00, 'proizvodi/7.jpg'),
    ('Samsung 990 PRO 2TB', 'SSD Komponenta', 320.00, 'proizvodi/8.jpg'),
    ('Razer DeathAdder V3', 'Gaming miš', 140.00, 'proizvodi/9.jpg'),
    ('HP EliteBook 860 G10', 'Poslovni računar', 2800.00, 'proizvodi/10.jpg'),
    ('ASUS ROG Strix B650-A', 'Matična ploča / Komponenta', 450.00, 'proizvodi/11.jpg'),
    ('HyperX Cloud III', 'Slušalice / Oprema', 180.00, 'proizvodi/12.jpg');
