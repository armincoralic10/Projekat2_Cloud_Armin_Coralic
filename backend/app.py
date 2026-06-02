from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import boto3
import os
import socket

app = Flask(__name__)
CORS(app)

S3_BUCKET = os.environ.get('S3_BUCKET', '')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')

s3_client = boto3.client('s3', region_name=AWS_REGION)


def get_db_connection():
    return psycopg2.connect(
        host=os.environ['DB_HOST'],
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD'],
    )


# Health check endpoint — koristi ga ALB Target Group, vraća i hostname EC2 instance
@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({"status": "ok", "instance": socket.gethostname()})


@app.route('/api/proizvodi', methods=['GET'])
def get_proizvodi():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id, naziv, kategorija, cijena, slika_kljuc FROM racunari;')
    proizvodi = [
        {
            "id": p[0],
            "naziv": p[1],
            "kategorija": p[2],
            "cijena": float(p[3]),
            "slika_kljuc": p[4],
        }
        for p in cur.fetchall()
    ]
    cur.close()
    conn.close()
    return jsonify(proizvodi)


@app.route('/api/proizvod/<int:proizvod_id>/slika', methods=['GET'])
def slika_proizvoda(proizvod_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT slika_kljuc FROM racunari WHERE id = %s', (proizvod_id,))
    red = cur.fetchone()
    cur.close()
    conn.close()

    if not red or not red[0]:
        return jsonify({"greska": "Slika nije pronađena"}), 404

    url = s3_client.generate_presigned_url(
        'get_object',
        Params={'Bucket': S3_BUCKET, 'Key': red[0]},
        ExpiresIn=3600,
    )
    return jsonify({"url": url})


@app.route('/api/korpa', methods=['GET', 'POST'])
def upravljanje_korpom():
    conn = get_db_connection()
    cur = conn.cursor()

    if request.method == 'POST':
        podaci = request.get_json()
        proizvod_id = podaci['proizvod_id']

        cur.execute('SELECT id, kolicina FROM korpa WHERE proizvod_id = %s', (proizvod_id,))
        postojeci = cur.fetchone()

        if postojeci:
            cur.execute('UPDATE korpa SET kolicina = kolicina + 1 WHERE id = %s', (postojeci[0],))
        else:
            cur.execute('INSERT INTO korpa (proizvod_id, kolicina) VALUES (%s, 1)', (proizvod_id,))

        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"poruka": "Dodano u korpu!"}), 201

    cur.execute('''
        SELECT k.id, r.naziv, r.cijena, k.kolicina
        FROM korpa k
        JOIN racunari r ON k.proizvod_id = r.id;
    ''')
    stavke = [
        {"id": s[0], "naziv": s[1], "cijena": float(s[2]), "kolicina": s[3]}
        for s in cur.fetchall()
    ]
    cur.close()
    conn.close()
    return jsonify(stavke)


@app.route('/api/korpa/<int:stavka_id>', methods=['DELETE'])
def obrisi_iz_korpe(stavka_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('DELETE FROM korpa WHERE id = %s', (stavka_id,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"poruka": "Stavka obrisana!"}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
