function Navbar({ username, onHome, onDashboard, onProfile, onLogout, page}){
    return (
        <nav className="navbar">
            <span className="navbar-logo">Močerad CT</span>
            <div className="navbar-links">
                <button className={page === 'home' ? 'active' : ''} onClick={onHome}>Domov</button>
                <button className={page === 'dashboard' ? 'active' : ''} onClick={onDashboard}>Dashboard</button>
                <button className={page === 'profile' ? 'active' : ''} onClick={onProfile}>Profil</button>
            </div>
            <div className="navbar-user">
                <span> {username}</span>
                <button className="btn-logout" onClick={onLogout}>Odjava</button>
            </div>
        </nav>
    );
}

export default Navbar;