
# PROJEKTNA NALOGA
## Analize masivnih podatkov za aplikacije v realnem svetu

Močerad CT je aplikacija za sledenje fitnesu in prehrani. Omogoča beleženje
aktivnosti (tudi v živo z GPS sledenjem), sledenje kaloričnemu vnosu, prepoznavanje
hrane s slike, pregled zgodovine na interaktivni mapi ter dostop do kataloga živil,
ki ga polni avtomatski scraper iz OpenFoodFacts.

**Avtorji:** Timotej Kompare, Aljaž Roglič, Lucija Grilj

---

## Servisi

Projekt je sestavljen iz več servisov. Vsak ima svojo podrobnejšo dokumentacijo:

| Servis | Tehnologija | Opis | Dokumentacija |
| ------ | ----------- | ---- | ------------- |
| **react-app** | React | Spletna aplikacija (uporabniški vmesnik) | [react-app/README.md](react-app/README.md) |
| **mobile** | Flutter | Mobilna aplikacija (Android/iOS) | [mobile/README.md](mobile/README.md) |
| **foodai** | Python / FastAPI | Prepoznavanje hrane s slike (AI) | [foodai/README.md](foodai/README.md) |
| **scraper** | Node.js | Zajem živil iz OpenFoodFacts | [scraper/README.md](scraper/README.md) |
| **mqtt-broker** | Mosquitto | Prenos telemetrije v živo | [mqtt-broker/README.md](mqtt-broker/README.md) |
| **supabase** | PostgreSQL | Podatkovna baza | [supabase/README.md](supabase/README.md) |

---

## Zahteve

Pred namestitvijo preverite, da imate nameščeno:

- [Docker](https://www.docker.com) (za zagon celotnega sistema)
- Git

Preverite namestitev:

```bash
docker --version
git --version
```

> Za razvoj posameznih servisov so potrebna še dodatna orodja (Node.js, Flutter,
> Python). Te zahteve so opisane v dokumentaciji vsakega servisa.

---

## Namestitev

### 1. Klonirajte repozitorij

```bash
git clone https://github.com/grilj-lucija/moceradi-project.git
cd moceradi-project
```

### 2. Nastavite spremenljivke okolja

Kopirajte primer `.env` datoteke in vnesite vaše Supabase podatke:

```bash
cp .env.example .env
```

```
REACT_APP_SUPABASE_URL=vas_supabase_url
REACT_APP_SUPABASE_KEY=vas_anon_key
SUPABASE_URL=vas_supabase_url
SUPABASE_SERVICE_KEY=vas_service_key
```

Za dostop do Supabase projekta vas mora administrator povabiti na **Settings → Team**.
Po povabilu najdete URL in ključe pod **Settings → API**. (Glej [supabase/README.md](supabase/README.md).)

### 3. Zaženite sistem

```bash
chmod +x start.sh
./start.sh
```

Skripta z Dockerjem zgradi in zažene vse servise. Po zagonu so dostopni:

- Spletna aplikacija → http://localhost:3000
- FoodAI API → http://localhost:8000
- MQTT → tcp://localhost:1883 (mqtt), ws://localhost:9001 (websockets)

Spremljanje dnevnikov: `docker compose logs -f`
Ustavitev: `docker compose down`

> Mobilna aplikacija se ne zgradi privzeto. Za zagon na napravi/emulatorju
> uporabite `./run-mobile.sh` (glej [mobile/README.md](mobile/README.md)).

---

## Primeri uporabe

### Primer 1: Dodajanje obroka v dnevnik prehrane

1. Prijavite se v aplikacijo
2. V navigaciji kliknite **Prehrana**
3. V iskalno polje vpišite ime živila (npr. "mleko")
4. Izberite živilo iz kataloga, vnesite količino in potrdite
5. Obrok se shrani v dnevnik skupaj s kaloričnim vnosom

### Primer 2: Ogled zgodovine aktivnosti na mapi

1. Prijavite se v aplikacijo
2. V navigaciji kliknite **Aktivnosti**
3. Izberite aktivnost iz seznama
4. Na interaktivni mapi se prikaže trasa vaše aktivnosti
5. Pod mapo so prikazani podatki: čas, razdalja, poraba kalorij

---

## GitHub Secrets (CI/CD)

Za avtomatske teste so Supabase ključi shranjeni kot GitHub Secrets:

```
- REACT_APP_SUPABASE_URL
- REACT_APP_SUPABASE_KEY
```

Nastavljeni so pod **Settings → Secrets and Variables → Actions**.

---

## Podatkovna baza

Projekt uporablja Supabase (PostgreSQL). Podatkovni model vključuje:

- **users** – uporabniki
- **activity** – zabeležene aktivnosti z lokacijskimi podatki
- **nutrition_log** – dnevnik prehrane
- **ingredient** – katalog živil

Več v [supabase/README.md](supabase/README.md).
