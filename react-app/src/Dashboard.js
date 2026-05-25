import {useState, useEffect} from 'react';
import { supabase } from './supabaseClient';
import { BarChart, Bar, XAxis, Tooltip, CartesianGrid, LineChart, Line, YAxis } from 'recharts';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

function Dashboard({ session}){
    const [activities, setActivities] = useState([]);

    useEffect(() => {
        fetchActivities();
    }, []);

    async function fetchActivities(){
        const {data, error} = await supabase
        .from('activities')
        .select('*')
        .eq('user_id', session.user.id)
        .order('started_at', {ascending: false});

        if(error) console.log(error);
        else setActivities(data);
    }

    // statistike
    const totalDistance = activities.reduce((sum, a) => sum + (a.distance_meters || 0), 0);
    const totalCalories = activities.reduce((sum, a) => sum + (a.calories_kcal || 0), 0);
    const totalDuration = activities.reduce((sum, a) => sum + (a.duration_seconds || 0), 0);

    // graf kalorij po aktivnostih 
    const caloriesData = activities.map(a => ({
        name: new Date(a.started_at).toLocaleDateString('sl-SI'),
        kalorije: Math.round(a.calories_kcal || 0)
    }));

    // graf razdalje 
    const distanceData = activities.map(a => ({
        name: new Date(a.started_at).toLocaleDateString('sl-SI'),
        razdalja: Math.round((a.calories_kcal || 0)/1000 * 100) / 100
    }));

    const statBox = {padding: '20px', border: '1px solid #ddd', borderRadius: '8px', textAlign: 'center', minWidth: '150px'};

    return (
        <div className='page-container'>
            <h2 className='section-title'>Dashboard</h2>

            <div className='stat-grid'>
                <div className='stat-card'>
                    <h3>Skupna razdalja</h3>
                    <p>{(totalDistance/1000).toFixed(2)} km</p>
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
                    <p>{activities.length}</p>
                </div>
            </div>
            <h3 className='section-title'>Kalorije po aktivnostih</h3>
            <div className='card'>
            <BarChart width={700} height={250} data={caloriesData} style={{marginBottom: '30px'}}>
                <CartesianGrid strokeDasharray="3 3"/>
                <XAxis dataKey="name" tick={{fontSize: 10}}/>
                <YAxis />
                <Tooltip />
                <Bar dataKey="kalorije" fill='#ff7300' name="Kalorije (kcal)"/>
            </BarChart>
            </div>

            <h3 className='section-title'>Razdalja po aktivnostih (km)</h3>
            <div className='card'>
            <BarChart width={700} height={250} data={distanceData} style={{marginBottom: '30px'}}>
                <CartesianGrid strokeDasharray="3 3"/>
                <XAxis dataKey="name" tick={{fontSize: 10}}/>
                <YAxis />
                <Tooltip />
                <Bar type="monotone" dataKey="razdalja" fill='#8884d8' name="Razdalja (km)"/>
            </BarChart>
            </div>

            <h3 className='section-title'>Lokacija</h3>
            <MapContainer center={[46.1512, 14.9955]} zoom={8} style={{ height: '400px', width: '100%', marginBottom: '30px'}}>
                <TileLayer url='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png' attribution='© OpenStreetMap'/>
                {activities.filter(a => a.start_lat && a.start_lng).map(a => (
                    <Marker key={a.id} position={[a.start_lat, a.start_lng]}>
                        <Popup>
                            <b>{a.type}</b><br />
                            {new Date(a.started_at).toLocaleDateString('sl-SI')}<br/>
                            {((a.distance_meters || 0) / 1000).toFixed(2)} km
                        </Popup>
                    </Marker>
                ))}
            </MapContainer>

            <h3 className='section-data'>Historia aktivnosti</h3>
            <div className='card'>
            <table className='data-table'>
                <thead>
                    <tr>
                        <th>Datum</th>
                        <th>Tip</th>
                        <th>Razdalja (km)</th>
                        <th>Čas (min)</th>
                        <th>Kalorije</th>
                        <th>Maks. hitrost (m/s)</th>
                    </tr>
                </thead>
                <tbody>
                    {activities.map(a => (
                        <tr key={a.id}>
                            <td>{new Date(a.started_at).toLocaleDateString('sl-SI')}</td>
                            <td>{a.type}</td>
                            <td>{((a.distance_meters || 0) / 1000).toFixed(2)}</td>
                            <td>{Math.round((a.duration_seconds || 0)/60)}</td>
                            <td>{(a.calories_kcal || 0).toFixed(0)}</td>
                            <td>{(a.max_speed_mps || 0).toFixed(2)}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
            </div>
        </div>
    );
}

export default Dashboard;