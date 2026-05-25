import {useState, useEffect} from 'react';
import { supabase } from './supabaseClient';

function Profile ({session, onBack}){
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
        <div style={{padding: '40px', maxWidth: '500px', margin: '0 auto'}}>
            <button onClick={onBack} style={{marginBottom: '20px'}}>Nazaj</button>
            <h2>Moj profil</h2>

            <table border="1" cellPadding="10" style={{ width: '100%'}}>
                <tbody>
                    <tr><td><b>Username</b></td><td>{profile.username || '-'}</td></tr>
                    <tr><td><b>Prikazano ime</b></td><td>{profile.display_name || '-'}</td></tr>
                    <tr><td><b>Email</b></td><td>{profile.email || '-'}</td></tr>
                    <tr><td><b>Spol</b></td><td>{profile.gender || '-'}</td></tr>
                    <tr><td><b>Datum rojstva</b></td><td>{profile.date_of_birth || '-'}</td></tr>
                    <tr><td><b>Višina</b></td><td>{profile.height_cm ? profile.height_cm + ' cm' : '-'}</td></tr>
                    <tr><td><b>Teža</b></td><td>{profile.weight_cm ? profile.weight_cm + ' kg' : '-'}</td></tr>
                </tbody>
            </table>
        </div>
    );
}

export default Profile;