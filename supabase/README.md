# Supabase (podatkovna baza)

[Supabase](https://supabase.com) (PostgreSQL) je centralna podatkovna baza projekta.
Hrani uporabnike, aktivnosti, dnevnik prehrane in katalog živil. Uporabljata jo
spletna in mobilna aplikacija, scraper pa vanjo polni živila.

Mapa vsebuje:

- `config.toml` – nastavitve za lokalni Supabase (preko Supabase CLI)
- `schema.sql` – izvoz celotne podatkovne sheme (tabele, funkcije, sprožilci)

## Podatkovni model

Glavne tabele v shemi `public`:

- **profiles** – profili uporabnikov
- **user_goals**, **user_weights**, **daily_nutrition_goals** – cilji in meritve uporabnika
- **activities**, **activity_streams** – zabeležene aktivnosti in njihovi podatkovni tokovi
- **walk**, **walk_node** – sprehodi z lokacijskimi točkami
- **food_entries** – dnevnik prehrane
- **ingredient** – katalog živil (polni ga scraper)
- **custom_foods**, **generic_foods**, **popular_foods**, **recent_foods** – viri in predlogi živil
- **recipes**, **recipe_ingredients** – recepti

> Celotna shema (vključno z `auth`, `storage` in `realtime`) je v `schema.sql`.

## Možnost A: Obstoječi (gostovani) projekt

Najlažja pot — uporabite obstoječi Supabase projekt v oblaku:

1. Administrator vas povabi na **Settings → Team**
2. URL in ključe najdete pod **Settings → API**
3. Te vrednosti vpišete v `.env` datoteke posameznih servisov

## Možnost B: Lokalni Supabase

### Zahteve

- [Docker](https://www.docker.com)
- [Supabase CLI](https://supabase.com/docs/guides/cli)

### Zagon

```bash
cd supabase
supabase start
```

Po zagonu CLI izpiše lokalne URL-je in ključe (API na `http://localhost:54321`,
Studio na `http://localhost:54323`).

Uvoz sheme v lokalno bazo:

```bash
psql "postgresql://postgres:postgres@localhost:54322/postgres" -f schema.sql
```

Ustavitev:

```bash
supabase stop
```

## Primeri uporabe

### Primer 1: Pridobitev ključev za aplikacije

Po `supabase start` izpisane vrednosti (`API URL`, `anon key`, `service_role key`)
prekopirajte v `.env` datoteke servisov:

- `react-app/.env` → `REACT_APP_SUPABASE_URL`, `REACT_APP_SUPABASE_KEY` (anon)
- `scraper/.env` → `SUPABASE_URL`, `SUPABASE_SERVICE_KEY` (service)
- `mobile/.env` → `SUPABASE_URL`, `SUPABASE_ANON_KEY` (anon)

### Primer 2: Pregled podatkov v Studiu

Odprite `http://localhost:54323` in v zavihku **Table Editor** preglejte tabele
(npr. `ingredient`), poganjajte SQL poizvedbe in urejajte zapise.
