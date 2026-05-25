
import React, { useState, useEffect} from 'react';
import {supabase} from './supabaseClient';
import { BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import MapView from './MapView';
import Auth from './Auth';

function App(){
  const [session, setSession] = useState(null);
  const [ingredients, setIngredients] = useState([]);
  const [search, setSearch] = useState('');
  const [username, setUsername] = useState();

  useEffect(() => {
    supabase.auth.getSession().then(({data: {session}}) => setSession(session));
    const {data: {subscription}} = supabase.auth.onAuthStateChange((_event, session) => setSession(session));
    fetchIngredients();
    return () => subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if(session) fetchUsername();
  }, [session]);

  async function fetchUsername(){
    const {data} = await supabase.from('profiles').select('username').eq('id', session.user.id).single();
    if(data) setUsername(data.username);
  }

  async function fetchIngredients() {
    const  {data, error} = await supabase.from('ingredient').select('*').limit(10);

    if(error) console.log(error);
    else setIngredients(data);
  }

  async function handleLogout(){
    await supabase.auth.signOut();
  }

  const filtered = ingredients.filter(i => i.name.toLowerCase().includes(search.toLocaleLowerCase()));

  const topTen = [...ingredients].filter(i => i.calorie_count).sort((a, b) => b.calorie_count - a.calorie_count).slice(0, 10);
  
  if(!session){
    return <Auth />
  }

  return (
    <div style={{padding: '20px'}}>
      <div style={{display: 'flex', justifyContent: 'space-between'}}>
      <h1>Močerad CT - Seznam živil</h1>
      <div>
        <span>Pozdravljeni, {username || session.user.email}</span>
        <button onClick={handleLogout} style={{marginLeft: '10px'}}>Odjava</button>
      </div>
      </div>
      <input type='text' placeholder='Išči živilo...' value={search} onChange={e => setSearch(e.target.value)} style={{padding: '8px', width: '300px', marginBottom: '20px'}}/>

      <h2>Top 10 živil po kaloričnosti</h2>
      <BarChart width={700} height={300} data={topTen}>
        <CartesianGrid strokeDasharray="3 3"/>
        <XAxis dataKey="name" tick={{fontSize: 10}} />
        <YAxis/>
        <Tooltip/>
        <Bar dataKey="calorie_count" fill='#8884d8' name="Kalorije (kcal)" />
      </BarChart>


      <h2>Vsa živila</h2>
      <table border="1" cellPadding="8">
        <thead>
          <tr>
            <th>Ime</th>
            <th>Kalorije (kcal)</th>
          </tr>
        </thead>
        <tbody>
          {filtered.map(item => (
            <tr key={item.id}>
              <td>{item.name}</td>
              <td>{item.calorie_count}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <MapView />
    </div>
  );
}

export default App;
