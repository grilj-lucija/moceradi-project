require('dotenv').config();
const axios = require('axios');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_KEY;

async function fetchFoods(page) {
    const url = `https://world.openfoodfacts.org/api/v2/search?countries_tags=slovenia&page_size=50&page=${page}&fields=product_name,nutriments`
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

function sleep(ms){
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    for(let page = 1; page <= 80; page++){
        console.log('Zajemam stran:', page);

        try{
        const products = await fetchFoods(page);

        if(!products || products.length === 0) break;

        for(const product of products){
            if(!product.nutriments) continue;
            const name = product.product_name;
            const calories = product.nutriments['energy-kcal_100g'];
    
            if(!name || !calories) continue;

            await saveIngredients(name, calories);
            console.log('Shranjeno:', name);
        }
    } catch (err){
        console.log('Napaka na strani', page, '-preskakujem');
    }

        await sleep(2000);
    }
}

main();