# Mobilna aplikacija (Flutter)

Mobilna aplikacija za Android in iOS. Omogoča prijavo, beleženje aktivnosti v živo
(GPS sledenje), pregled prehrane in fotografiranje hrane za samodejno prepoznavanje
preko storitve FoodAI. Med aktivnostjo pošilja telemetrijo na MQTT posrednik.

## Zahteve

- [Flutter](https://docs.flutter.dev/get-started/install) 3.x (vključuje Dart 3.x)
- Android Studio ali Xcode (za emulator/simulator), ali fizična naprava
- Delujoči ostali servisi (Supabase, FoodAI, MQTT) za poln način delovanja

Preverite namestitev:

```bash
flutter doctor
flutter devices
```

## Namestitev

```bash
cd mobile
flutter pub get
cp .env.example .env
```

Odprite `.env` in nastavite spremenljivke. Za hiter preizkus brez backenda
pustite `USE_MOCK_DATA=true` (aplikacija uporabi vzorčne podatke).

```
USE_MOCK_DATA=true
SUPABASE_URL=vas_supabase_url
SUPABASE_ANON_KEY=vas_anon_key
FOODAI_BASE_URL=http://<IP-racunalnika>:8000
MQTT_HOST=<IP-racunalnika>
MQTT_PORT=1883
```

Za povezavo na lokalne servise lahko iz korenske mape uporabite pomožno skripto,
ki samodejno zazna IP in nastavi `.env`:

```bash
./run-mobile.sh
```

## Primeri uporabe

### Primer 1: Zagon na napravi/emulatorju

```bash
flutter run
```

Če imate več naprav, izberite določeno:

```bash
flutter devices
flutter run -d "iPhone 15"
flutter run -d emulator-5554
```

V demo načinu (`USE_MOCK_DATA=true`) se prijavite z:

```
email:    demo@health.app
geslo:    demo1234
```

### Primer 2: Beleženje aktivnosti v živo

1. Prijavite se v aplikacijo
2. Začnite novo aktivnost (npr. tek)
3. Aplikacija med snemanjem pošilja lokacijo in hitrost na MQTT posrednik
4. Na spletni aplikaciji lahko hkrati spremljate aktivnost v realnem času
5. Po koncu se aktivnost shrani v Supabase in je vidna v zgodovini

## Pogosti ukazi

```bash
flutter analyze     # statična analiza kode
flutter test        # zagon testov
flutter build apk   # gradnja Android APK
```
