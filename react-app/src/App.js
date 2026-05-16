
import React, { useState, useEffect} from 'react';
import {supabase} from './supabaseClient';
import { BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import MapView from './MapView';

function App(){
  const [ingredients, setIngredients] = useState([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchIngredients();
  }, []);

  async function fetchIngredients() {
    const  {data, error} = await supabase.from('ingredient').select('*').limit(10);

    if(error) console.log(error);
    else setIngredients(data);
  }

  const filtered = ingredients.filter(i => i.name.toLowerCase().includes(search.toLocaleLowerCase()));

  const topTen = [...ingredients].filter(i => i.calorie_count).sort((a, b) => b.calorie_count - a.calorie_count).slice(0, 10);

  return (
    <div style={{padding: '20px'}}>
      <h1>Močerad CT - Seznam živil</h1>
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
