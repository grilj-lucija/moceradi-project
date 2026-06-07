# Scraper (zajem živil)

Skripta v Node.js, ki samodejno zajame podatke o živilih z
[OpenFoodFacts](https://world.openfoodfacts.org/) in jih shrani v Supabase
tabelo `ingredient` (ime živila in kalorije na 100 g). Zajame angleška in
slovenska živila ter preskoči nepopolne ali neveljavne zapise.

## Zahteve

- [Node.js](https://nodejs.org) 18+
- Dostop do Supabase projekta (URL in service ključ)

## Namestitev

```bash
cd scraper
npm install
cp .env .env   # ali ustvarite .env ročno (glej spodaj)
```

V datoteko `.env` vnesite:

```
SUPABASE_URL=vas_supabase_url
SUPABASE_SERVICE_KEY=vas_service_key
OFF_USER_AGENT=moceradi-project - Student project - email@example.com
```

> Uporablja se **service** ključ (ne anon), saj scraper piše v bazo.

## Primeri uporabe

### Primer 1: Zagon zajema

```bash
node scraper.js
```

Med zajemom skripta sproti izpisuje napredek:

```
=== Zajemam angleska zivila ===
Zajemam anglesko stran 1...
Shranjeno: 48 živil (skupaj: 48, preskočeno: 2)
...
Koncano! Shranjeno: 1234, preskoceno: 56
```

### Primer 2: Zagon testov

```bash
npm test
```

Testi (Jest) preverijo čiščenje imen in obdelavo strani brez klica na bazo.

## Opomba

OpenFoodFacts API je javen, zato je med zahtevami vgrajen zamik (2 s),
da ne preobremenimo storitve.
