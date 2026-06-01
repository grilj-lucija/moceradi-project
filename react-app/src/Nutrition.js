import { useState, useEffect, useCallback } from 'react';
import { supabase } from './supabaseClient';
import { PieChart, Pie, Cell, Tooltip, Legend } from 'recharts';

const MACRO_COLORS = { Beljakovine: '#3fb950', 'Ogljikovi hidrati': '#d29922', Maščobe: '#f85149' };

const MEAL_LABELS = {
  breakfast: 'Zajtrk',
  lunch: 'Kosilo',
  dinner: 'Večerja',
  snack: 'Prigrizki',
};

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function MacroBar({ label, value, goal, unit, color }) {
  const pct = goal > 0 ? Math.min(100, (value / goal) * 100) : 0;
  return (
    <div className='macro-row'>
      <div className='macro-head'>
        <span>{label}</span>
        <span>{Math.round(value)} / {Math.round(goal)} {unit}</span>
      </div>
      <div className='macro-track'>
        <div className='macro-fill' style={{ width: `${pct}%`, backgroundColor: color }} />
      </div>
    </div>
  );
}

function DiaryView({ session }) {
  const [date, setDate] = useState(todayISO());
  const [entries, setEntries] = useState([]);
  const [goal, setGoal] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    setLoading(true);
    const start = new Date(`${date}T00:00:00`);
    const end = new Date(start);
    end.setDate(end.getDate() + 1);

    const [entriesRes, goalRes] = await Promise.all([
      supabase
        .from('food_entries')
        .select('*')
        .eq('user_id', session.user.id)
        .gte('logged_at', start.toISOString())
        .lt('logged_at', end.toISOString())
        .order('logged_at', { ascending: true }),
      supabase
        .from('daily_nutrition_goals')
        .select('*')
        .eq('user_id', session.user.id)
        .maybeSingle(),
    ]);

    if (entriesRes.error) console.log(entriesRes.error);
    else setEntries(entriesRes.data || []);

    if (goalRes.error) console.log(goalRes.error);
    else setGoal(goalRes.data);

    setLoading(false);
  }, [date, session.user.id]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const macrosFor = (entry) => {
    const factor = (entry.grams || 0) / 100;
    return {
      kcal: (entry.food_kcal_per_100g || 0) * factor,
      protein: (entry.food_protein_per_100g || 0) * factor,
      carbs: (entry.food_carbs_per_100g || 0) * factor,
      fat: (entry.food_fat_per_100g || 0) * factor,
    };
  };

  const totals = entries.reduce((acc, e) => {
    const m = macrosFor(e);
    acc.kcal += m.kcal;
    acc.protein += m.protein;
    acc.carbs += m.carbs;
    acc.fat += m.fat;
    return acc;
  }, { kcal: 0, protein: 0, carbs: 0, fat: 0 });

  const liquidsMl = entries
    .filter(e => e.food_is_beverage)
    .reduce((s, e) => s + (e.grams || 0), 0);

  const macroPie = [
    { name: 'Beljakovine', value: Math.round(totals.protein * 4) },
    { name: 'Ogljikovi hidrati', value: Math.round(totals.carbs * 4) },
    { name: 'Maščobe', value: Math.round(totals.fat * 9) },
  ].filter(d => d.value > 0);

  return (
    <>
      <div className='nutrition-header'>
        <span className='section-title' style={{ margin: 0 }}>Dnevni vnos</span>
        <input
          className='search-input'
          type='date'
          value={date}
          max={todayISO()}
          onChange={e => setDate(e.target.value)}
          style={{ width: '200px', marginBottom: 0 }}
        />
      </div>

      {loading ? (
        <p>Nalagam...</p>
      ) : (
        <>
          <div className={macroPie.length > 0 ? 'nutrition-top' : 'nutrition-top single'}>
            <div className='card'>
              <MacroBar label='Kalorije' value={totals.kcal} goal={goal?.kcal || 0} unit='kcal' color='#00d4ff' />
              <MacroBar label='Beljakovine' value={totals.protein} goal={goal?.protein_grams || 0} unit='g' color='#3fb950' />
              <MacroBar label='Ogljikovi hidrati' value={totals.carbs} goal={goal?.carbs_grams || 0} unit='g' color='#d29922' />
              <MacroBar label='Maščobe' value={totals.fat} goal={goal?.fat_grams || 0} unit='g' color='#f85149' />
              <MacroBar label='Tekočine' value={liquidsMl} goal={goal?.liquids_ml || 0} unit='ml' color='#58a6ff' />
            </div>

            {macroPie.length > 0 && (
              <div className='card nutrition-pie-card'>
                <span className='section-title' style={{ marginTop: 0 }}>Razrez kalorij po makrih</span>
                <PieChart width={320} height={220}>
                  <Pie data={macroPie} dataKey='value' nameKey='name' cx='50%' cy='50%' outerRadius={75} label={({ percent }) => `${Math.round(percent * 100)}%`}>
                    {macroPie.map(d => <Cell key={d.name} fill={MACRO_COLORS[d.name]} />)}
                  </Pie>
                  <Tooltip formatter={(v) => `${v} kcal`} />
                  <Legend />
                </PieChart>
              </div>
            )}
          </div>

          <h3 className='section-title'>Vnešena hrana</h3>
          <div className='card'>
            {entries.length === 0 ? (
              <p>Za izbrani dan ni vnešene hrane.</p>
            ) : (
              <table className='data-table'>
                <thead>
                  <tr>
                    <th>Živilo</th>
                    <th>Obrok</th>
                    <th>Količina</th>
                    <th>kcal</th>
                    <th>B</th>
                    <th>OH</th>
                    <th>M</th>
                  </tr>
                </thead>
                <tbody>
                  {entries.map(e => {
                    const m = macrosFor(e);
                    return (
                      <tr key={e.id}>
                        <td>
                          {e.food_name}
                          {e.food_brand ? <span className='food-brand'> · {e.food_brand}</span> : null}
                        </td>
                        <td>{MEAL_LABELS[e.meal_slot] || e.meal_slot}</td>
                        <td>{Math.round(e.grams)} g</td>
                        <td>{Math.round(m.kcal)}</td>
                        <td>{m.protein.toFixed(1)} g</td>
                        <td>{m.carbs.toFixed(1)} g</td>
                        <td>{m.fat.toFixed(1)} g</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
          </div>
        </>
      )}
    </>
  );
}

function CatalogView() {
  const PAGE_SIZE = 20;
  const [foods, setFoods] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(0);
  const [total, setTotal] = useState(0);

  const fetchFoods = useCallback(async (query, pageIndex) => {
    setLoading(true);
    const columns = 'id, name, category, kcal_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, sugar_per_100g';
    const fromRow = pageIndex * PAGE_SIZE;
    const toRow = fromRow + PAGE_SIZE - 1;

    let request = supabase
      .from('generic_foods')
      .select(columns, { count: 'exact' })
      .order('priority', { ascending: false })
      .order('name', { ascending: true })
      .range(fromRow, toRow);

    if (query.length >= 2) {
      request = supabase
        .from('generic_foods')
        .select(columns, { count: 'exact' })
        .ilike('name', `%${query}%`)
        .order('priority', { ascending: false })
        .order('name', { ascending: true })
        .range(fromRow, toRow);
    }

    const { data, error, count } = await request;
    if (error) console.log(error);
    else {
      setFoods(data || []);
      setTotal(count || 0);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    setPage(0);
  }, [search]);

  useEffect(() => {
    const trimmed = search.trim();
    const handle = setTimeout(() => fetchFoods(trimmed, page), 300);
    return () => clearTimeout(handle);
  }, [search, page, fetchFoods]);

  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  return (
    <>
      <input
        className='search-input'
        type='text'
        placeholder='Išči živilo (min. 2 znaka)...'
        value={search}
        onChange={e => setSearch(e.target.value)}
      />

      <h3 className='section-title'>{loading ? 'Nalagam...' : `Živila (${total})`}</h3>
      <div className='card'>
        <table className='data-table'>
          <thead>
            <tr>
              <th>Ime</th>
              <th>Kategorija</th>
              <th>kcal /100g</th>
              <th>Beljakovine</th>
              <th>Ogljikovi h.</th>
              <th>Maščobe</th>
              <th>Sladkor</th>
            </tr>
          </thead>
          <tbody>
            {foods.map(item => (
              <tr key={item.id}>
                <td>{item.name}</td>
                <td>{item.category || '-'}</td>
                <td>{Math.round(item.kcal_per_100g)}</td>
                <td>{(item.protein_per_100g || 0).toFixed(1)} g</td>
                <td>{(item.carbs_per_100g || 0).toFixed(1)} g</td>
                <td>{(item.fat_per_100g || 0).toFixed(1)} g</td>
                <td>{(item.sugar_per_100g || 0).toFixed(1)} g</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {total > 0 && (
        <div className='pagination'>
          <button disabled={page === 0} onClick={() => setPage(p => Math.max(0, p - 1))}>← Prejšnja</button>
          <span>Stran {page + 1} / {totalPages}</span>
          <button disabled={page + 1 >= totalPages} onClick={() => setPage(p => p + 1)}>Naslednja →</button>
        </div>
      )}
    </>
  );
}

function Nutrition({ session }) {
  const [tab, setTab] = useState('diary');

  return (
    <div className='page-container'>
      <h2 className='section-title'>Prehrana</h2>
      <div className='subtabs'>
        <button className={tab === 'diary' ? 'active' : ''} onClick={() => setTab('diary')}>Dnevnik</button>
        <button className={tab === 'catalog' ? 'active' : ''} onClick={() => setTab('catalog')}>Katalog živil</button>
      </div>

      {tab === 'diary' ? <DiaryView session={session} /> : <CatalogView />}
    </div>
  );
}

export default Nutrition;
