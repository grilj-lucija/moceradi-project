import {useState, useEffect} from 'react';
import { supabase } from './supabaseClient';

function Profile ({session}){
    const [profile, setProfile] = useState(null);

    useEffect(() => {
        fetchProfile();
    }, []);

    async function fetchProfile() {
        const {data, error} = await supabase
        .from('profiles')
        .select('*')
        .eq('id', session.user.id)
        .single();

        if(error && error.code == 'PGRST116'){
            const {data: newProfile} = await supabase
            .from('profiles')
            .insert({
                id: session.user.id,
                email: session.user.email
            })
            .select()
            .single()
            if(newProfile) setProfile(newProfile);
        }
        else if(data){
            setProfile(data);
        }
    }
    if(!profile){
        return <p>Nalagam...</p>;
    }

    return (
        <div className='page-container' style={{maxWidth: '600'}}>
            <h2 className='section-title'>Moj profil</h2>
            <div className='card'>
            <table className='data-table'>
                <tbody>
                    <tr><td><b>Username</b></td><td>{profile.username || '-'}</td></tr>
                    <tr><td><b>Prikazano ime</b></td><td>{profile.display_name || '-'}</td></tr>
                    <tr><td><b>Email</b></td><td>{profile.email || '-'}</td></tr>
                    <tr><td><b>Spol</b></td><td>{profile.gender || '-'}</td></tr>
                    <tr><td><b>Datum rojstva</b></td><td>{profile.date_of_birth || '-'}</td></tr>
                    <tr><td><b>Višina</b></td><td>{profile.height_cm ? profile.height_cm + ' cm' : '-'}</td></tr>
                    <tr><td><b>Teža</b></td><td>{profile.weight_kg ? profile.weight_kg + ' kg' : '-'}</td></tr>
                </tbody>
            </table>
        </div>
    </div>
    );
}

export default Profile;