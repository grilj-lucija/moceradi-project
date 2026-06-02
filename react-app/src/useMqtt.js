import { useEffect, useRef, useState } from 'react';
import mqtt from 'mqtt';

const WS_URL = process.env.REACT_APP_MQTT_WS_URL || 'ws://localhost:9001';
const STALE_MS = 30000;
const MAX_TRAIL = 5000;

export function useMqtt(userId) {
  const [connected, setConnected] = useState(false);
  const [devices, setDevices] = useState({});
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
          const trail =
            typeof data.lat === 'number' && typeof data.lng === 'number'
              ? [...cur.trail, [data.lat, data.lng]].slice(-MAX_TRAIL)
              : cur.trail;
          return {
            ...prev,
            [deviceId]: {
              ...cur,
              telemetry: data,
              status: 'online',
              lastSeen: now,
              trail,
            },
          };
        }
        const becameOnline = data.status === 'online' && cur.status !== 'online';
        return {
          ...prev,
          [deviceId]: {
            ...cur,
            status: data.status,
            presenceTs: data.ts,
            lastSeen: now,
            trail: becameOnline ? [] : cur.trail,
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
    const interval = setInterval(() => {
      setDevices((prev) => {
        let changed = false;
        const next = {};
        const now = Date.now();
        for (const [id, d] of Object.entries(prev)) {
          if (d.status === 'online' && now - d.lastSeen > STALE_MS) {
            next[id] = { ...d, status: 'stale' };
            changed = true;
          } else {
            next[id] = d;
          }
        }
        return changed ? next : prev;
      });
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const deviceList = Object.entries(devices).map(([id, d]) => ({ id, ...d }));
  const activeDevices = deviceList.filter((d) => d.status === 'online');

  return { connected, devices: deviceList, activeDevices, activeCount: activeDevices.length };
}
