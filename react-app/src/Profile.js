import { useState, useEffect, useCallback } from 'react';
import { supabase } from './supabaseClient';
import { LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid, ResponsiveContainer } from 'recharts';

const ACTIVITY_METRIC_LABELS = {
  cycling_distance: 'Kolesarjenje (razdalja)',
  running_distance: 'Tek (razdalja)',
  walking_distance: 'Hoja (razdalja)',
  active_minutes: 'Aktivne minute',
  calories_burned: 'Porabljene kalorije',
  workouts: 'Število treningov',
};

const PERIOD_LABELS = { day: 'dan', week: 'teden', month: 'mesec' };
const PACE_LABELS = { easy: 'Umirjeno', balanced: 'Uravnoteženo', aggressive: 'Agresivno' };

const GENDER_LABELS = { male: 'Moški', female: 'Ženska', other: 'Drugo' };

const ACTIVITY_LEVEL_LABELS = {
  sedentary: 'Sedeč',
  light: 'Lahka aktivnost',
  moderate: 'Zmerna aktivnost',
  active: 'Aktiven',
  athlete: 'Športnik',
};

const INTENT_LABELS = {
  lose_weight: 'Izguba teže',
  gain_weight: 'Pridobivanje teže',
  build_endurance: 'Vzdržljivost',
  improve_general_fitness: 'Splošna kondicija',
  run_a_5k: 'Tek na 5 km',
  build_strength: 'Moč',
};

function Profile({ session }) {
  const [profile, setProfile] = useState(null);
  const [goals, setGoals] = useState(null);
  const [weights, setWeights] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchAll = useCallback(async () => {
    setLoading(true);
    const [profileRes, goalsRes, weightsRes] = await Promise.all([
      supabase.from('profiles').select('*').eq('id', session.user.id).maybeSingle(),
      supabase.from('user_goals').select('*').eq('user_id', session.user.id).maybeSingle(),
      supabase
        .from('user_weights')
        .select('*')
        .eq('user_id', session.user.id)
        .order('week_start', { ascending: true }),
    ]);

    if (profileRes.data) setProfile(profileRes.data);
    if (goalsRes.data) setGoals(goalsRes.data);
    if (weightsRes.data) setWeights(weightsRes.data);
    setLoading(false);
  }, [session.user.id]);

  useEffect(() => {
    fetchAll();
  }, [fetchAll]);

  if (loading) return <div className='page-container'><p>Nalagam...</p></div>;

  const weightData = weights.map(w => ({
    name: new Date(w.week_start).toLocaleDateString('sl-SI'),
    teza: Number(w.weight_kg),
  }));

  return (
    <div className='page-container'>
      <h2 className='section-title'>Moj profil</h2>

      <div className='profile-head'>
        {profile?.avatar_url ? (
          <img className='profile-avatar' src={profile.avatar_url} alt='avatar' />
        ) : (
          <div className='profile-avatar profile-avatar-empty'>
            {(profile?.display_name || profile?.username || session.user.email || '?')[0].toUpperCase()}
          </div>
        )}
        <div>
          <div className='profile-name'>{profile?.display_name || profile?.username || '-'}</div>
          <div className='profile-email'>{profile?.email || session.user.email}</div>
        </div>
      </div>

      <div className='card'>
        <table className='data-table'>
          <tbody>
            <tr><td><b>Uporabniško ime</b></td><td>{profile?.username || '-'}</td></tr>
            <tr><td><b>Prikazano ime</b></td><td>{profile?.display_name || '-'}</td></tr>
            <tr><td><b>Spol</b></td><td>{profile?.gender ? (GENDER_LABELS[profile.gender] || profile.gender) : '-'}</td></tr>
            <tr><td><b>Datum rojstva</b></td><td>{profile?.date_of_birth || '-'}</td></tr>
            <tr><td><b>Višina</b></td><td>{profile?.height_cm ? profile.height_cm + ' cm' : '-'}</td></tr>
            <tr><td><b>Teža</b></td><td>{profile?.weight_kg ? profile.weight_kg + ' kg' : '-'}</td></tr>
            <tr><td><b>Ciljna teža</b></td><td>{profile?.target_weight_kg ? profile.target_weight_kg + ' kg' : '-'}</td></tr>
            <tr><td><b>Raven aktivnosti</b></td><td>{profile?.activity_level ? (ACTIVITY_LEVEL_LABELS[profile.activity_level] || profile.activity_level) : '-'}</td></tr>
          </tbody>
        </table>
      </div>

      <h3 className='section-title'>Cilji</h3>
      <div className='card'>
        <table className='data-table'>
          <tbody>
            <tr>
              <td><b>Nameni</b></td>
              <td>{goals?.intents?.length ? goals.intents.map(i => INTENT_LABELS[i] || i).join(', ') : '-'}</td>
            </tr>
            <tr>
              <td><b>Tedenski cilj</b></td>
              <td>
                {goals?.activity_metric
                  ? `${ACTIVITY_METRIC_LABELS[goals.activity_metric] || goals.activity_metric}: ${goals.activity_target ?? '-'} / ${PERIOD_LABELS[goals.activity_period] || goals.activity_period}`
                  : '-'}
              </td>
            </tr>
            <tr>
              <td><b>Tempo</b></td>
              <td>{goals?.pace ? (PACE_LABELS[goals.pace] || goals.pace) : '-'}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <h3 className='section-title'>Zgodovina teže</h3>
      {weightData.length > 0 ? (
        <>
          <div className='card'>
            <ResponsiveContainer width='100%' height={250}>
              <LineChart data={weightData}>
                <CartesianGrid strokeDasharray='3 3' />
                <XAxis dataKey='name' tick={{ fontSize: 10 }} />
                <YAxis domain={['dataMin - 2', 'dataMax + 2']} />
                <Tooltip />
                <Line type='monotone' dataKey='teza' stroke='#00d4ff' name='Teža (kg)' />
              </LineChart>
            </ResponsiveContainer>
          </div>
          <div className='card'>
            <table className='data-table'>
              <thead>
                <tr><th>Teden (od)</th><th>Teža (kg)</th></tr>
              </thead>
              <tbody>
                {[...weights].reverse().map(w => (
                  <tr key={w.id}>
                    <td>{new Date(w.week_start).toLocaleDateString('sl-SI')}</td>
                    <td>{Number(w.weight_kg).toFixed(1)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      ) : (
        <div className='card'><p>Ni zabeleženih meritev teže.</p></div>
      )}
    </div>
  );
}

export default Profile;
