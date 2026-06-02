import { useEffect } from 'react';
import { MapContainer, TileLayer, Polyline, CircleMarker, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import { useMqtt } from './useMqtt';

const TYPE_LABELS = { walking: 'Hoja', running: 'Tek', cycling: 'Kolesarjenje' };
const PACE_TYPES = ['walking', 'running'];

function formatDuration(seconds) {
  const s = Math.max(0, Math.round(seconds || 0));
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  if (h > 0) return `${h}:${String(m).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
  return `${m}:${String(sec).padStart(2, '0')}`;
}

function formatPace(secPerKm) {
  if (!secPerKm || !isFinite(secPerKm)) return '-';
  const m = Math.floor(secPerKm / 60);
  const s = Math.round(secPerKm % 60);
  return `${m}:${String(s).padStart(2, '0')}`;
}

function Metric({ label, value, unit }) {
  return (
    <div className='metric-tile'>
      <div className='metric-label'>{label}</div>
      <div className='metric-value'>
        {value}{unit ? <span className='metric-unit'> {unit}</span> : null}
      </div>
    </div>
  );
}

function Recenter({ point }) {
  const map = useMap();
  useEffect(() => {
    if (point) map.setView(point, map.getZoom(), { animate: true });
  }, [point, map]);
  return null;
}

function LiveDeviceCard({ device }) {
  const t = device.telemetry || {};
  const trail = device.trail || [];
  const last = trail.length > 0 ? trail[trail.length - 1] : null;
  const usesPace = PACE_TYPES.includes(t.type);
  const speedMps = t.speedMps != null
    ? t.speedMps
    : (t.durationS > 0 ? (t.distanceM || 0) / t.durationS : 0);
  const speedValue = usesPace
    ? formatPace(speedMps > 0 ? 1000 / speedMps : 0)
    : (speedMps * 3.6).toFixed(1);
  const speedLabel = usesPace ? 'Tempo' : 'Hitrost';
  const speedUnit = usesPace ? '/km' : 'km/h';

  return (
    <div className='card' style={{ marginBottom: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
        <h3 className='section-title' style={{ margin: 0 }}>
          {TYPE_LABELS[t.type] || t.type || 'Aktivnost'}
        </h3>
        <span className='live-badge'>● V ŽIVO</span>
      </div>
      <div className='profile-email' style={{ marginBottom: '12px', fontSize: '12px' }}>
        Naprava: {device.id.slice(0, 8)}
      </div>

      <div style={{ borderRadius: '12px', overflow: 'hidden', marginBottom: '16px' }}>
        {last ? (
          <MapContainer style={{ height: '280px', width: '100%' }} center={last} zoom={16} scrollWheelZoom={false}>
            <TileLayer
              url='https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
              attribution='© OpenStreetMap, © CARTO'
            />
            {trail.length > 1 && (
              <Polyline positions={trail} pathOptions={{ color: '#00d4ff', weight: 4 }} />
            )}
            <CircleMarker center={last} radius={7} pathOptions={{ color: '#00d4ff', fillColor: '#00d4ff', fillOpacity: 1 }} />
            <Recenter point={last} />
          </MapContainer>
        ) : (
          <div style={{ padding: '40px', textAlign: 'center', color: '#8b949e' }}>
            Čakam na GPS lokacijo...
          </div>
        )}
      </div>

      <div className='metric-grid'>
        <Metric label='Razdalja' value={((t.distanceM || 0) / 1000).toFixed(2)} unit='km' />
        <Metric label='Trajanje' value={formatDuration(t.durationS)} />
        <Metric label={speedLabel} value={speedValue} unit={speedUnit} />
        <Metric label='Kalorije' value={t.caloriesKcal == null ? '—' : Math.round(t.caloriesKcal)} unit={t.caloriesKcal == null ? '' : 'kcal'} />
        <Metric label='Nadm. višina' value={t.altitude == null ? '—' : Math.round(t.altitude)} unit={t.altitude == null ? '' : 'm'} />
        <Metric label='Pospešek' value={t.accel ? Math.sqrt(t.accel.x ** 2 + t.accel.y ** 2 + t.accel.z ** 2).toFixed(1) : '—'} unit={t.accel ? 'm/s²' : ''} />
      </div>
    </div>
  );
}

function LiveActivity({ session }) {
  const userId = session?.user?.id;
  const { connected, activeDevices, activeCount } = useMqtt(userId);

  return (
    <div className='page-container'>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
        <h2 className='section-title' style={{ margin: 0 }}>Aktivnosti v živo</h2>
        <span className={`conn-pill ${connected ? 'conn-on' : 'conn-off'}`}>
          {connected ? 'Povezan' : 'Ni povezave'}
        </span>
      </div>

      <div className='card' style={{ marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '12px' }}>
        <div className='metric-value' style={{ fontSize: '32px' }}>{activeCount}</div>
        <div className='metric-label'>
          {activeCount === 1 ? 'aktivna naprava' : 'aktivnih naprav'}
        </div>
      </div>

      {activeDevices.length === 0 ? (
        <div className='card' style={{ padding: '40px', textAlign: 'center', color: '#8b949e' }}>
          Trenutno ni aktivnih naprav. Začni aktivnost v mobilni aplikaciji.
        </div>
      ) : (
        activeDevices.map((device) => <LiveDeviceCard key={device.id} device={device} />)
      )}
    </div>
  );
}

export default LiveActivity;
