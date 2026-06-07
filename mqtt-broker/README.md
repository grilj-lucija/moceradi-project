# MQTT Broker (Mosquitto)

Self-hosted [Eclipse Mosquitto](https://mosquitto.org/) broker that relays live
workout telemetry from the mobile app (publisher) to the web app (subscriber).

## Listeners

| Port | Protocol   | Used by                         |
| ---- | ---------- | ------------------------------- |
| 1883 | MQTT (TCP) | Flutter mobile app (publisher)  |
| 9001 | WebSockets | React web app via mqtt.js (sub) |

Browsers cannot speak raw MQTT over TCP, so the web client connects to the
WebSockets listener on `9001`.

## Run

```bash
cd mqtt-broker
docker compose up -d
```

Stop:

```bash
docker compose down
```

View logs:

```bash
docker compose logs -f
```

## Topics

| Topic                                   | Payload                                     | Notes                       |
| --------------------------------------- | ------------------------------------------- | --------------------------- |
| `health/telemetry/<userId>/<deviceId>`  | live sensor JSON (GPS, speed, distance, ...) | published while recording   |
| `health/presence/<userId>/<deviceId>`   | `{ "status": "online" \| "offline", ... }`   | retained, with Last Will    |

Per-user separation is done by topic: the web app subscribes only to
`health/telemetry/<myUserId>/#` and `health/presence/<myUserId>/#`.

## Auth

Anonymous access is enabled for local development (`allow_anonymous true`). When
hosting publicly, add a password file and TLS, and set `allow_anonymous false`.
