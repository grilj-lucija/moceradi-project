require('dotenv').config();
const axios = require('axios');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_KEY;

async function fetchFoods() {
    const url = 'https://world.openfoodfacts.org/api/v2/search?categories_tags=fruits&page_size=20&fields=product_name,nutriments'
    const response = await axios.get(url, {
        headers:{
            'User-Agent': 'moceradi-project - Student project - lucija@example.com'
        }
    });
    return response.data.products;
}   

async function saveIngredients(name, calories) {
    await axios.post(
        SUPABASE_URL + '/rest/v1/ingredient',
        {name: name, calorie_count: Math.round(calories)},
        {
            headers: {
                'apikey': SUPABASE_KEY,
                'Authorization': 'Bearer ' + SUPABASE_KEY,
                'Content-Type': 'application/json'
            }
        }
    );
}

async function main() {
    const products = await fetchFoods();
    for(const product of products){
        const name = product.product_name;
        const calories = product.nutriments['energy-kcal_100g'];
    
    if(!name || !calories) continue;

    await saveIngredients(name, calories);
    console.log('Shranjeno:', name);
    }
}

main();