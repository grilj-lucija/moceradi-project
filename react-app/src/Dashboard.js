import { useState, useEffect, useCallback } from 'react';
import { supabase } from './supabaseClient';
import { BarChart, Bar, XAxis, Tooltip, CartesianGrid, YAxis, PieChart, Pie, Cell, Legend, ResponsiveContainer } from 'recharts';
import ActivityDetail from './ActivityDetail';

const TYPE_LABELS = { walking: 'Hoja', running: 'Tek', cycling: 'Kolesarjenje' };
const TYPE_COLORS = { walking: '#3fb950', running: '#ff7300', cycling: '#8884d8' };

const METRIC_LABELS = {
    cycling_distance: 'Kolesarjenje',
    running_distance: 'Tek',
    walking_distance: 'Hoja',
    active_minutes: 'Aktivne minute',
    calories_burned: 'Porabljene kalorije',
    workouts: 'Treningi',
};
const METRIC_UNITS = {
    cycling_distance: 'km',
    running_distance: 'km',
    walking_distance: 'km',
    active_minutes: 'min',
    calories_burned: 'kcal',
    workouts: '',
};
const PERIOD_LABELS = { day: 'danes', week: 'ta teden', month: 'ta mesec' };

function isoDaysAgo(days) {
    const d = new Date();
    d.setDate(d.getDate() - days);
    return d.toISOString().slice(0, 10);
}

function todayISO() {
    return new Date().toISOString().slice(0, 10);
}

function periodStart(period) {
    const now = new Date();
    if (period === 'day') return new Date(now.getFullYear(), now.getMonth(), now.getDate());
    if (period === 'month') return new Date(now.getFullYear(), now.getMonth(), 1);
    const day = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekday = (day.getDay() + 6) % 7;
    day.setDate(day.getDate() - weekday);
    return day;
}

function singleMetric(metric, a) {
    switch (metric) {
        case 'cycling_distance': return a.type === 'cycling' ? (a.distance_meters || 0) / 1000 : 0;
        case 'running_distance': return a.type === 'running' ? (a.distance_meters || 0) / 1000 : 0;
        case 'walking_distance': return a.type === 'walking' ? (a.distance_meters || 0) / 1000 : 0;
        case 'active_minutes': return (a.duration_seconds || 0) / 60;
        case 'calories_burned': return a.calories_kcal || 0;
        case 'workouts': return 1;
        default: return 0;
    }
}

function GoalRing({ fraction, label, valueText }) {
    const radius = 52;
    const circ = 2 * Math.PI * radius;
    const clamped = Math.max(0, Math.min(1, fraction));
    return (
        <div className='goal-ring'>
            <svg width='130' height='130' viewBox='0 0 130 130'>
                <circle cx='65' cy='65' r={radius} fill='none' stroke='#21262d' strokeWidth='12' />
                <circle
                    cx='65' cy='65' r={radius} fill='none' stroke='#00d4ff' strokeWidth='12'
                    strokeLinecap='round'
                    strokeDasharray={circ}
                    strokeDashoffset={circ * (1 - clamped)}
                    transform='rotate(-90 65 65)'
                />
                <text x='65' y='62' textAnchor='middle' fontSize='22' fontWeight='bold' fill='#e0e0e0'>
                    {Math.round(clamped * 100)}%
                </text>
                <text x='65' y='84' textAnchor='middle' fontSize='11' fill='#8b949e'>
                    {valueText}
                </text>
            </svg>
            <div className='goal-ring-label'>{label}</div>
        </div>
    );
}

function Dashboard({ session }) {
    const [activities, setActivities] = useState([]);
    const [goals, setGoals] = useState(null);
    const [selected, setSelected] = useState(null);
    const [from, setFrom] = useState(isoDaysAgo(30));
    const [to, setTo] = useState(todayISO());

    const fetchData = useCallback(async () => {
        const [actRes, goalRes] = await Promise.all([
            supabase
                .from('activities')
                .select('*')
                .eq('user_id', session.user.id)
                .order('started_at', { ascending: false }),
            supabase
                .from('user_goals')
                .select('*')
                .eq('user_id', session.user.id)
                .maybeSingle(),
        ]);

        if (actRes.error) console.log(actRes.error);
        else setActivities(actRes.data || []);

        if (goalRes.error) console.log(goalRes.error);
        else setGoals(goalRes.data);
    }, [session.user.id]);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    if (selected) {
        return <ActivityDetail activity={selected} session={session} onBack={() => setSelected(null)} />;
    }

    const fromTime = from ? new Date(`${from}T00:00:00`).getTime() : -Infinity;
    const toTime = to ? new Date(`${to}T23:59:59.999`).getTime() : Infinity;
    const filtered = activities.filter(a => {
        const t = new Date(a.started_at).getTime();
        return t >= fromTime && t <= toTime;
    });

    const applyPreset = (days) => {
        if (days === null) {
            const oldest = activities[activities.length - 1];
            setFrom(oldest ? new Date(oldest.started_at).toISOString().slice(0, 10) : isoDaysAgo(365));
        } else {
            setFrom(isoDaysAgo(days));
        }
        setTo(todayISO());
    };

    const totalDistance = filtered.reduce((sum, a) => sum + (a.distance_meters || 0), 0);
    const totalCalories = filtered.reduce((sum, a) => sum + (a.calories_kcal || 0), 0);
    const totalDuration = filtered.reduce((sum, a) => sum + (a.duration_seconds || 0), 0);

    const dayBuckets = new Map();
    for (const a of filtered) {
        const d = new Date(a.started_at);
        const key = `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`;
        if (!dayBuckets.has(key)) dayBuckets.set(key, { kalorije: 0, razdalja: 0 });
        const b = dayBuckets.get(key);
        b.kalorije += a.calories_kcal || 0;
        b.razdalja += (a.distance_meters || 0) / 1000;
    }

    const dailySeries = [];
    if (isFinite(fromTime) && isFinite(toTime) && fromTime <= toTime) {
        const cursor = new Date(fromTime);
        cursor.setHours(0, 0, 0, 0);
        const last = new Date(toTime);
        while (cursor <= last) {
            const key = `${cursor.getFullYear()}-${cursor.getMonth()}-${cursor.getDate()}`;
            const b = dayBuckets.get(key);
            dailySeries.push({
                name: cursor.toLocaleDateString('sl-SI', { day: '2-digit', month: '2-digit' }),
                kalorije: b ? Math.round(b.kalorije) : 0,
                razdalja: b ? Math.round(b.razdalja * 100) / 100 : 0,
            });
            cursor.setDate(cursor.getDate() + 1);
        }
    }

    const typeData = Object.keys(TYPE_LABELS).map(type => ({
        type,
        name: TYPE_LABELS[type],
        value: filtered.filter(a => a.type === type).reduce((s, a) => s + (a.distance_meters || 0) / 1000, 0),
    })).filter(d => d.value > 0).map(d => ({ ...d, value: Math.round(d.value * 100) / 100 }));

    let goalCard = null;
    if (goals && goals.activity_metric && goals.activity_target > 0) {
        const period = goals.activity_period || 'week';
        const since = periodStart(period).getTime();
        const value = activities
            .filter(a => new Date(a.started_at).getTime() >= since)
            .reduce((s, a) => s + singleMetric(goals.activity_metric, a), 0);
        const unit = METRIC_UNITS[goals.activity_metric];
        const rounded = unit === 'km' ? value.toFixed(1) : Math.round(value);
        goalCard = {
            fraction: value / goals.activity_target,
            label: `${METRIC_LABELS[goals.activity_metric]} · ${PERIOD_LABELS[period]}`,
            valueText: `${rounded} / ${goals.activity_target} ${unit}`,
        };
    }

    return (
        <div className='page-container'>
            <h2 className='section-title'>Dashboard</h2>

            <div className='range-bar'>
                <div className='range-dates'>
                    <label>
                        Od
                        <input className='search-input' type='date' value={from} max={to || todayISO()} onChange={e => setFrom(e.target.value)} />
                    </label>
                    <label>
                        Do
                        <input className='search-input' type='date' value={to} min={from} max={todayISO()} onChange={e => setTo(e.target.value)} />
                    </label>
                </div>
                <div className='range-presets'>
                    <button onClick={() => applyPreset(7)}>7 dni</button>
                    <button onClick={() => applyPreset(30)}>30 dni</button>
                    <button onClick={() => applyPreset(90)}>90 dni</button>
                    <button onClick={() => applyPreset(null)}>Vse</button>
                </div>
            </div>

            <div className='stat-grid'>
                <div className='stat-card'>
                    <h3>Skupna razdalja</h3>
                    <p>{(totalDistance / 1000).toFixed(2)} km</p>
                </div>
                <div className='stat-card'>
                    <h3>Skupne kalorije</h3>
                    <p>{totalCalories.toFixed(0)} kcal</p>
                </div>
                <div className='stat-card'>
                    <h3>Skupni čas</h3>
                    <p>{Math.round(totalDuration / 60)} min</p>
                </div>
                <div className='stat-card'>
                    <h3>Število aktivnosti</h3>
                    <p>{filtered.length}</p>
                </div>
            </div>

            {(goalCard || typeData.length > 0) && (
                <div className='insight-row'>
                    {goalCard && (
                        <div className='card insight-card'>
                            <h3 className='section-title' style={{ marginTop: 0 }}>Napredek proti cilju</h3>
                            <GoalRing fraction={goalCard.fraction} label={goalCard.label} valueText={goalCard.valueText} />
                        </div>
                    )}
                    {typeData.length > 0 && (
                        <div className='card insight-card'>
                            <h3 className='section-title' style={{ marginTop: 0 }}>Razdalja po tipu (km)</h3>
                            <PieChart width={280} height={200}>
                                <Pie data={typeData} dataKey='value' nameKey='name' cx='50%' cy='50%' outerRadius={70} label>
                                    {typeData.map(d => <Cell key={d.type} fill={TYPE_COLORS[d.type]} />)}
                                </Pie>
                                <Tooltip />
                                <Legend />
                            </PieChart>
                        </div>
                    )}
                </div>
            )}

            <h3 className='section-title'>Kalorije po dnevih</h3>
            <div className='card'>
                <ResponsiveContainer width='100%' height={250}>
                    <BarChart data={dailySeries}>
                        <CartesianGrid strokeDasharray='3 3' />
                        <XAxis dataKey='name' tick={{ fontSize: 10 }} />
                        <YAxis />
                        <Tooltip />
                        <Bar dataKey='kalorije' fill='#ff7300' name='Kalorije (kcal)' />
                    </BarChart>
                </ResponsiveContainer>
            </div>

            <h3 className='section-title'>Razdalja po dnevih (km)</h3>
            <div className='card'>
                <ResponsiveContainer width='100%' height={250}>
                    <BarChart data={dailySeries}>
                        <CartesianGrid strokeDasharray='3 3' />
                        <XAxis dataKey='name' tick={{ fontSize: 10 }} />
                        <YAxis />
                        <Tooltip />
                        <Bar dataKey='razdalja' fill='#8884d8' name='Razdalja (km)' />
                    </BarChart>
                </ResponsiveContainer>
            </div>

            <h3 className='section-title'>Zgodovina aktivnosti</h3>
            <div className='card'>
                <table className='data-table'>
                    <thead>
                        <tr>
                            <th>Datum</th>
                            <th>Tip</th>
                            <th>Razdalja (km)</th>
                            <th>Čas (min)</th>
                            <th>Kalorije</th>
                            <th>Maks. hitrost (km/h)</th>
                        </tr>
                    </thead>
                    <tbody>
                        {filtered.map(a => (
                            <tr key={a.id} onClick={() => setSelected(a)} className='clickable-row'>
                                <td>{new Date(a.started_at).toLocaleDateString('sl-SI')}</td>
                                <td>{TYPE_LABELS[a.type] || a.type}</td>
                                <td>{((a.distance_meters || 0) / 1000).toFixed(2)}</td>
                                <td>{Math.round((a.duration_seconds || 0) / 60)}</td>
                                <td>{(a.calories_kcal || 0).toFixed(0)}</td>
                                <td>{((a.max_speed_mps || 0) * 3.6).toFixed(1)}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
                {filtered.length === 0 && <p style={{ marginTop: '12px' }}>Ni aktivnosti v izbranem obdobju.</p>}
            </div>
        </div>
    );
}

export default Dashboard;
