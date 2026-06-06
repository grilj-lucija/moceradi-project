
# PROJEKTNA NALOGA
## Analize masivnih podatkov za aplikacije v realnem svetu

Močerad CT je spletna aplikacija za sledenje fitnesu in prehrani. Omogoča beleženje aktivnosti, sledenje kaloričnemu vnosu, pregled zgodovine na interaktivni mapi ter dostopa do kataloga živil, ki ga polni avtomatski scraper iz OpenFoodFacts.

**Avtorji:** Timotej Kompare, Aljaž Roglič, Lucija Grilj

---

## Tehnologije
- **Mobilna aplikacija:** Flutter
- **Frontend:** React
- **Podatkovna baza:** Supabase (PostgreSQL)
- **Scraper:** Node.js
- **Kontejnarizacija:** Docker

---

## Zahteve
Pred namestitvijo preverite, da imate nameščeno:

- [Node.js](https://node.js.org) v18 ali novejši
- [Docker](https://www.docker.com) (za zagon s kontejnerji)
- Git

Preverite namestitev:
```bash
node --version # mora biti v18+
docker --version
git --version
```


---

## Namestitev

### 1. Klonirajte repozitorij

```bash
git clone https://github.com/grilj-lucija/moceradi-project.git
cd moceradi-projekt
```

### 2. Nastavite spremenljivke okolja 

Kopirajte primer `.env` datoteke:

```bash
cp .env.example .env
```

Odprite `.env` in vnesite vaše Supabase podatke:

```
REACT_APP_SUPABASE_URL=vas_supabase_url
REACT_APP_SUPABASE_KEY=vas_anon_key
```

Za scraper nastavite še:

```
cp scraper/.env.example scraper/.env
```

Odprite `scraper/.env` in vnesite:

```
SUPABASE_URL=vas_supabase_url
SUPABASE_KEY=supabase_key
```

Za dostop do Supabase projekta vas mora administrator povabiti na **Settings -> Team**.
Po povabilu najdete URL in ključe pod **Settings -> API**.

### 3.Zaženite aplikacijo 

Možnost A: Z dockerjem (priporočeno)

V terminal vnesite spodnji ukaz:

```
chmod +x start.sh
./start.sh
```

Aplikacija se bo samodejno odprla na (http://localhost:3000)

Možnost B: Brez Dockerja

V terminal po vrsti vnesite spodnje ukaze:

```
cd react-app
npm install --legacy-peer-deps
npm start
```

Aplikacija bo dostopna na (http://localhost:3000)


## GitHub Secrets (CI/CD)

Za avtomatske teste so Supabase ključi shranjeni kot GitHub Secrets:

```
- REACT_APP_SUPABASE_URL
- REACT_APP_SUPABASE_KEY
```

Nastavljeni so pod Settings -> Secrets and Variables -> Actions.

## Primeri uporabe

### Primer 1: Dodajanje obroka v dnevnik prehrane

1. Prijavite se v aplikacijo
2. V navigaciji kliknite Prehrana
3. Kliknite Dodaj obrok
4. V iskalno polje vpišite ime živila (npr. "mleko")
5. Izberite živilo iz kataloga
6. Vnesite količino in potrdite
7. Obrok se shrani v dnevnik skupaj s kaloričnim vnosom

### Primer 2: Ogled zgodovine aktivnosti na mapi

1. Prijavite se v aplikacijo
2. V navigaciji kliknite Aktivnosti
3. Izberite aktivnost iz seznama 
4. Na interaktivni mapi se prikaže trasa vaše aktivnosti
5. Pod mapo so prikazani podatki: čas, razdalja, poraba kalorij



## Podatkovna baza
Projekt uporablja Supabase (PostgreSQL). Podatkovni model vključuje:
- **users** - uporabniki
- **activity** - zabeležene aktivnosti z lokacijskimi podatki
- **nutrition_log** - dnevnik prehrane
- **ingredient** - katalog živil 