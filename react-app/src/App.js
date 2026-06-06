import React, { useState, useEffect } from 'react';
import { supabase } from './supabaseClient';
import Auth from './Auth';
import Profile from './Profile';
import Dashboard from './Dashboard';
import Nutrition from './Nutrition';
import Navbar from './Navbar';

function App() {
  const [session, setSession] = useState(null);
  const [username, setUsername] = useState();
  const [page, setPage] = useState('dashboard');

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => setSession(session));
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => setSession(session));
    return () => subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if (session) fetchUsername();
  }, [session]);

  async function fetchUsername() {
    const { data } = await supabase.from('profiles').select('username').eq('id', session.user.id).single();
    if (data) setUsername(data.username);
  }

  async function handleLogout() {
    await supabase.auth.signOut();
  }

  if (!session) return <Auth />;

  return (
    <div>
      <Navbar
        username={username || session.user.email}
        onDashboard={() => setPage('dashboard')}
        onNutrition={() => setPage('nutrition')}
        onProfile={() => setPage('profile')}
        onLogout={handleLogout}
        page={page}
      />
      {page === 'dashboard' && <Dashboard session={session} />}
      {page === 'nutrition' && <Nutrition session={session} />}
      {page === 'profile' && <Profile session={session} />}
    </div>
  );
}

export default App;
