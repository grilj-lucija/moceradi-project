import {useState} from 'react';
import {supabase} from './supabaseClient';

function Auth(){
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [username, setUsername] = useState('');
    const [isLogin, setIsLogin] = useState(true);
    const [message, setMessage] = useState('');

    async function handleSubmit() 
    {
        if(isLogin){
            const {data, error: fetchError} = await supabase
                .from('profiles')
                .select('email')
                .eq('username', username)
                .single();

            if(fetchError || !data){
                    setMessage('Uporabnik ne obstaja');
                    return;
                }
            const {error: loginError} = await supabase.auth.signInWithPassword({
                email: data.email,
                password
            });    

            if(loginError){
                setMessage(loginError.message);
            }
        }
        else{
                const {data, error} = await supabase.auth.signUp({email, password});
                console.log('signUp data: ', data);
                console.log('singUp error: ', error);
                if(error){
                    setMessage(error.message);
                }
                else{
                    const {error: insertError} =  await supabase.from('profiles').upsert({
                        id: data.user.id,
                        username: username,
                        email: email
                    });
                    console.log('insert error: ', insertError);
                    setMessage('Registracija uspešna! Prijavi se');
                }
            }
        }
    return (
        <div style={{ padding: '40px', maxWidth: '400px', margin: '0 auto'}}>
            <h2>{isLogin ? 'Prijava' : 'Registracija'}</h2>
            {!isLogin && (
                <input placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} style={{ display: 'block', width: '100%', padding: '8px', marginBottom: '10px'}}/>
            )}
            <input placeholder="Username"  value={username} onChange={e => setUsername(e.target.value)} style={{ display: 'block', width: '100%', padding: '8px', marginBottom: '10px'}}/>
            <input placeholder="Geslo" type="password" value={password} onChange={e => setPassword(e.target.value)} style={{ display: 'block', width: '100%', padding: '8px', marginBottom: '10px'}}/>
            <button onClick={handleSubmit} style={{ padding: '8px 20px'}}>
                {isLogin ? 'Prijavi se' : 'Registriraj se'}
            </button>
            <p style={{ cursor: 'pointer', color: 'blue'}} onClick={() => setIsLogin(!isLogin)}>
                {isLogin ? 'Nimaš računa? Registriraj se' : 'Že imaš račun? Prijavi se'}
            </p>
            {message && <p>{message}</p>}
        </div>
    );
           
}

export default Auth;