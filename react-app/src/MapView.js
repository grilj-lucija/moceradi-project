import React from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";

const locations = [
    {id: 1, name: 'Mercator Ljubljana', lat: 46.0569, lng: 14.5058, type: 'trgovina' },
    {id: 2, name: 'Spar Maribor', lat: 46.5547, lng: 15.6459, type: 'trgovina' },
    {id: 3, name: 'Hofer Celje', lat: 46.2313, lng: 15.2617, type: 'trgovina' },
    {id: 4, name: 'Mcdonald\'s Ljubljana', lat: 46.0511, lng: 14.5069, type: 'restavracija' },
    {id: 5, name: 'Restavracija Slovenija', lat: 46.1512, lng: 14.9955, type: 'restavracija' },
];

function MapView(){
    return (
        <div>
            <h2>Lokacije trgovin in restavracij</h2>
            <MapContainer center={[46.1512, 14.9955]} zoom={8} style={{height: '400px', width: '100%'}}>
                <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" attribution="© OpenStreetMap"/>
                {locations.map(loc => (
                    <Marker key={loc.id} position={[loc.lat, loc.lng]}>
                        <Popup>
                            <b>{loc.name}</b><br />
                            Tip: {loc.type}
                        </Popup>
                    </Marker>
                ))}

            </MapContainer>
        </div>
    );
}

export default MapView;