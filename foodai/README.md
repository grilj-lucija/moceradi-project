# FoodAI

Storitev za prepoznavanje hrane s slike. Uporablja naučen model (EfficientNet-B3, PyTorch)
in vrne ime živila, zanesljivost napovedi ter okvirne kalorije na 100 g.
Dostopna je preko preprostega REST API-ja (FastAPI).

## Zahteve

- [Docker](https://www.docker.com) (priporočeno), ali
- [Python](https://www.python.org) 3.12+ (za zagon brez Dockerja)

## Namestitev

### Možnost A: Docker (priporočeno)

Iz korenske mape projekta storitev zaženete skupaj z ostalimi (`./start.sh`),
ali pa samo FoodAI iz te mape:

```bash
cd foodai
docker compose up --build -d
```

Storitev je nato dostopna na `http://localhost:8000`.

### Možnost B: Brez Dockerja

```bash
cd foodai
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r server/requirements.txt
uvicorn server.main:app --host 0.0.0.0 --port 8000
```

## Primeri uporabe

### Primer 1: Prepoznavanje hrane s slike

Pošljite sliko na končno točko `/recognize`:

```bash
curl -X POST http://localhost:8000/recognize \
  -F "file=@banana.jpg"
```

Odgovor:

```json
{
  "label": "banana",
  "confidence": 0.97,
  "cal_100g": 89
}
```

### Primer 2: Pregled API-ja v brskalniku

Odprite `http://localhost:8000/docs`. Tam je samodejno generirana dokumentacija,
kjer lahko slike naložite in testirate prepoznavanje neposredno iz brskalnika.

Za preverjanje, ali storitev deluje:

```bash
curl http://localhost:8000/health
# -> {"status":"ok"}
```
