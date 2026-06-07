# Spletna aplikacija (React)

Spletni vmesnik aplikacije Močerad CT. Omogoča prijavo, nadzorno ploščo,
pregled aktivnosti na interaktivni mapi, dnevnik prehrane in spremljanje
aktivnosti v živo (preko MQTT). Podatke bere iz Supabase.

## Zahteve

- [Node.js](https://nodejs.org) 18+
- Dostop do Supabase projekta (URL in anon ključ)
- (neobvezno) delujoč MQTT posrednik za spremljanje v živo

## Namestitev

```bash
cd react-app
npm install --legacy-peer-deps
cp .env.example .env
```

Odprite `.env` in vnesite vaše podatke:

```
REACT_APP_SUPABASE_URL=vas_supabase_url
REACT_APP_SUPABASE_KEY=vas_anon_key
REACT_APP_MQTT_WS_URL=ws://localhost:9001
```

Zagon razvojnega strežnika:

```bash
npm start
```

Aplikacija se odpre na `http://localhost:3000`.

## Primeri uporabe

### Primer 1: Ogled zgodovine aktivnosti na mapi

1. Prijavite se v aplikacijo
2. Izberite aktivnost iz seznama
3. Na interaktivni mapi se izriše trasa aktivnosti
4. Pod mapo so prikazani podatki: čas, razdalja, poraba kalorij

### Primer 2: Dodajanje obroka v dnevnik prehrane

1. Odprite zavihek Prehrana
2. V iskalno polje vpišite ime živila (npr. "mleko")
3. Izberite živilo iz kataloga in vnesite količino
4. Obrok se shrani skupaj s kaloričnim vnosom

## Gradnja za produkcijo

```bash
npm run build
```

Rezultat je v mapi `build/` in pripravljen za namestitev (npr. preko Dockerja
skupaj z ostalimi servisi).
