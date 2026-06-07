# MQTT posrednik (Mosquitto)

Lasten [Eclipse Mosquitto](https://mosquitto.org/) posrednik, ki v realnem času
prenaša telemetrijo vadbe od mobilne aplikacije (objavlja) do spletne aplikacije
(naroča). Tako lahko na spletu spremljate aktivnost, ki poteka na telefonu, v živo.

## Zahteve

- [Docker](https://www.docker.com)

## Vrata (porti)

| Vrata | Protokol   | Uporablja                          |
| ----- | ---------- | ---------------------------------- |
| 1883  | MQTT (TCP) | mobilna aplikacija (objavlja)      |
| 9001  | WebSockets | spletna aplikacija (naroča)        |

Brskalniki ne znajo govoriti surovega MQTT preko TCP, zato se spletna aplikacija
poveže na WebSockets vrata `9001`.

## Namestitev

```bash
cd mqtt-broker
docker compose up -d
```

Posrednik teče v ozadju. Ustavitev:

```bash
docker compose down
```

## Primeri uporabe

### Primer 1: Pregled dnevnika (ali servis deluje)

```bash
docker compose logs -f
```

V dnevniku vidite povezave odjemalcev in promet sporočil.

### Primer 2: Ročni test naročanja na telemetrijo

Z nameščenim `mosquitto_clients` se lahko naročite na vse teme in opazujete
sporočila, ki jih pošilja mobilna aplikacija:

```bash
mosquitto_sub -h localhost -p 1883 -t "health/#" -v
```

## Teme (topics)

| Tema                                   | Vsebina                                | Opomba                    |
| -------------------------------------- | -------------------------------------- | ------------------------- |
| `health/telemetry/<userId>/<deviceId>` | senzorski JSON (GPS, hitrost, razdalja)| med snemanjem aktivnosti  |
| `health/presence/<userId>/<deviceId>`  | `{ "status": "online"/"offline" }`     | zadržano, z Last Will     |

Ločevanje med uporabniki poteka preko tem: spletna aplikacija se naroči samo na
`health/telemetry/<svojUserId>/#`.

## Avtentikacija

Za lokalni razvoj je vklopljen anonimni dostop (`allow_anonymous true`). Za javno
gostovanje dodajte datoteko z gesli in TLS ter nastavite `allow_anonymous false`.
