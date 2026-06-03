import { useEffect, useRef, useState } from 'react';
import mqtt from 'mqtt';

const WS_URL = process.env.REACT_APP_MQTT_WS_URL || 'ws://localhost:9001';
const PRESENCE_STALE_MS = 30000;
const ACTIVITY_TTL_MS = 5000;
const MAX_TRAIL = 5000;

export function useMqtt(userId) {
  const [connected, setConnected] = useState(false);
  const [devices, setDevices] = useState({});
  const [, setTick] = useState(0);
  const clientRef = useRef(null);

  useEffect(() => {
    if (!userId) return undefined;

    const client = mqtt.connect(WS_URL, {
      clientId: `web-${userId.slice(0, 8)}-${Math.random().toString(16).slice(2, 8)}`,
      reconnectPeriod: 2000,
      clean: true,
    });
    clientRef.current = client;

    const telemetryTopic = `health/telemetry/${userId}/+`;
    const presenceTopic = `health/presence/${userId}/+`;

    client.on('connect', () => {
      setConnected(true);
      client.subscribe([telemetryTopic, presenceTopic]);
    });
    client.on('reconnect', () => setConnected(false));
    client.on('close', () => setConnected(false));
    client.on('error', () => {});

    client.on('message', (topic, payload) => {
      let data;
      try {
        data = JSON.parse(payload.toString());
      } catch {
        return;
      }
      const parts = topic.split('/');
      const kind = parts[1];
      const deviceId = parts[3];
      if (!deviceId) return;
      const now = Date.now();

      setDevices((prev) => {
        const cur = prev[deviceId] || { trail: [] };
        if (kind === 'telemetry') {
          if (data.ended) {
            return {
              ...prev,
              [deviceId]: {
                ...cur,
                telemetry: { ...cur.telemetry, ...data },
                lastTelemetryAt: now,
                ended: true,
                presence: 'online',
                presenceSeenAt: now,
              },
            };
          }
          const wasLive =
            cur.lastTelemetryAt && now - cur.lastTelemetryAt < ACTIVITY_TTL_MS && !cur.ended;
          const baseTrail = wasLive ? cur.trail : [];
          const trail =
            typeof data.lat === 'number' && typeof data.lng === 'number'
              ? [...baseTrail, [data.lat, data.lng]].slice(-MAX_TRAIL)
              : baseTrail;
          return {
            ...prev,
            [deviceId]: {
              ...cur,
              telemetry: data,
              lastTelemetryAt: now,
              ended: false,
              presence: 'online',
              presenceSeenAt: now,
              trail,
            },
          };
        }
        return {
          ...prev,
          [deviceId]: {
            ...cur,
            presence: data.status,
            presenceTs: data.ts,
            presenceSeenAt: now,
          },
        };
      });
    });

    return () => {
      client.end(true);
      clientRef.current = null;
    };
  }, [userId]);

  useEffect(() => {
    const interval = setInterval(() => setTick((t) => t + 1), 1000);
    return () => clearInterval(interval);
  }, []);

  const now = Date.now();
  const deviceList = Object.entries(devices).map(([id, d]) => ({ id, ...d }));

  const connectedDevices = deviceList.filter(
    (d) => d.presence === 'online' && now - (d.presenceSeenAt || 0) < PRESENCE_STALE_MS,
  );
  const liveActivities = deviceList.filter(
    (d) => d.lastTelemetryAt && now - d.lastTelemetryAt < ACTIVITY_TTL_MS,
  );

  return {
    connected,
    connectedDevices,
    connectedCount: connectedDevices.length,
    liveActivities,
  };
}
