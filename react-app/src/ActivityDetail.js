import { useState, useEffect, useCallback } from 'react';
import { supabase } from './supabaseClient';
import { MapContainer, TileLayer, Polyline, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

const TYPE_LABELS = { walking: 'Hoja', running: 'Tek', cycling: 'Kolesarjenje' };
const PACE_TYPES = ['walking', 'running'];

function decodePolyline(encoded) {
  const out = [];
  let index = 0;
  let lat = 0;
  let lng = 0;
  while (index < encoded.length) {
    let result = 0;
    let shift = 0;
    let b;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dLat = (result & 1) !== 0 ? ~(result >> 1) : (result >> 1);
    lat += dLat;
    result = 0;
    shift = 0;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dLng = (result & 1) !== 0 ? ~(result >> 1) : (result >> 1);
    lng += dLng;
    out.push([lat / 1e5, lng / 1e5]);
  }
  return out;
}

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

function FitBounds({ points }) {
  const map = useMap();
  useEffect(() => {
    if (points && points.length > 0) {
      map.fitBounds(points, { padding: [24, 24] });
    }
  }, [points, map]);
  return null;
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

function ActivityDetail({ activity, session, onBack }) {
  const [points, setPoints] = useState(null);

  const fetchRoute = useCallback(async () => {
    const { data } = await supabase
      .from('activity_streams')
      .select('lats, lngs')
      .eq('activity_id', activity.id)
      .maybeSingle();

    if (data && data.lats && data.lngs && data.lats.length > 0) {
      const pts = data.lats.map((lat, i) => [lat, data.lngs[i]]);
      setPoints(pts);
    } else if (activity.summary_polyline) {
      setPoints(decodePolyline(activity.summary_polyline));
    } else {
      setPoints([]);
    }
  }, [activity.id, activity.summary_polyline]);

  useEffect(() => {
    fetchRoute();
  }, [fetchRoute]);

  const usesPace = PACE_TYPES.includes(activity.type);
  const avgSpeed = activity.duration_seconds > 0 ? activity.distance_meters / activity.duration_seconds : 0;
  const speedValue = usesPace ? formatPace(avgSpeed > 0 ? 1000 / avgSpeed : 0) : (avgSpeed * 3.6).toFixed(1);
  const speedLabel = usesPace ? 'Povp. tempo' : 'Povp. hitrost';
  const speedUnit = usesPace ? '/km' : 'km/h';

  const started = new Date(activity.started_at);

  return (
    <div className='page-container'>
      <button className='btn-back' onClick={onBack}>← Nazaj</button>

      <h2 className='section-title'>{activity.title || TYPE_LABELS[activity.type] || activity.type}</h2>
      <div className='profile-email' style={{ marginBottom: '16px' }}>
        {TYPE_LABELS[activity.type] || activity.type} · {started.toLocaleDateString('sl-SI')} · {started.toLocaleTimeString('sl-SI', { hour: '2-digit', minute: '2-digit' })}
      </div>

      <div className='card' style={{ padding: 0, overflow: 'hidden' }}>
        {points && points.length > 0 ? (
          <MapContainer style={{ height: '320px', width: '100%' }} center={points[0]} zoom={13} scrollWheelZoom={false}>
            <TileLayer
              url='https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
              attribution='© OpenStreetMap, © CARTO'
            />
            <Polyline positions={points} pathOptions={{ color: '#00d4ff', weight: 4 }} />
            <FitBounds points={points} />
          </MapContainer>
        ) : (
          <div style={{ padding: '40px', textAlign: 'center', color: '#8b949e' }}>
            {points === null ? 'Nalagam pot...' : 'Za to aktivnost ni zabeležene poti.'}
          </div>
        )}
      </div>

      <div className='metric-grid'>
        <Metric label='Razdalja' value={((activity.distance_meters || 0) / 1000).toFixed(2)} unit='km' />
        <Metric label='Trajanje' value={formatDuration(activity.duration_seconds)} />
        <Metric label={speedLabel} value={speedValue} unit={speedUnit} />
        <Metric label='Kalorije' value={activity.calories_kcal == null ? '—' : Math.round(activity.calories_kcal)} unit={activity.calories_kcal == null ? '' : 'kcal'} />
        <Metric label='Vzpon' value={activity.elevation_gain_meters == null ? '—' : Math.round(activity.elevation_gain_meters)} unit={activity.elevation_gain_meters == null ? '' : 'm'} />
        <Metric label='Maks. hitrost' value={activity.max_speed_mps == null ? '—' : (activity.max_speed_mps * 3.6).toFixed(1)} unit={activity.max_speed_mps == null ? '' : 'km/h'} />
        <Metric label='Povp. srčni utrip' value={activity.avg_heart_rate == null ? '—' : activity.avg_heart_rate} unit={activity.avg_heart_rate == null ? '' : 'bpm'} />
        <Metric label='Maks. srčni utrip' value={activity.max_heart_rate == null ? '—' : activity.max_heart_rate} unit={activity.max_heart_rate == null ? '' : 'bpm'} />
      </div>
    </div>
  );
}

export default ActivityDetail;
