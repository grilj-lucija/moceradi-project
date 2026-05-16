
import React, { useState, useEffect} from 'react';
import {supabase} from './supabaseClient';

function App(){
  const [ingredients, setIngredients] = useState([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchIngredients();
  }, []);

  async function fetchIngredients() {
    const  {data, error} = await supabase.from('ingredient').select('*').limit(100);

    if(error) console.log(error);
    else setIngredients(data);
  }

  const filtered = ingredients.filter(i => i.name.toLowerCase().includes(search.toLocaleLowerCase()));

  return (
    <div style={{padding: '20px'}}>
      <h1>Močerad CT - Seznam živil</h1>
      <input type='text' placeholder='Išči živilo...' value={search} onChange={e => setSearch(e.target.value)} style={{padding: '8px', width: '300px', marginBottom: '20px'}}/>
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
    </div>
  );
}

export default App;
