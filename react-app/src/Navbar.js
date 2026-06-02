function Navbar({ username, onDashboard, onLive, onNutrition, onProfile, onLogout, page }) {
    return (
        <nav className="navbar">
            <span className="navbar-logo">Močerad CT</span>
            <div className="navbar-links">
                <button className={page === 'dashboard' ? 'active' : ''} onClick={onDashboard}>Dashboard</button>
                <button className={page === 'live' ? 'active' : ''} onClick={onLive}>V živo</button>
                <button className={page === 'nutrition' ? 'active' : ''} onClick={onNutrition}>Prehrana</button>
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
