require('dotenv').config();
const axios = require('axios');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_KEY;

async function fetchFoods(url) {
    const response = await axios.get(url, {
        headers:{
            'User-Agent': 'moceradi-project - Student project - lucija@example.com'
        },
        timeout: 10000
    });
    return response.data.products;
}   

async function saveIngredients(items) {
    await axios.post(
        SUPABASE_URL + '/rest/v1/ingredient',
        items,
        {
            headers: {
                'apikey': SUPABASE_KEY,
                'Authorization': 'Bearer ' + SUPABASE_KEY,
                'Content-Type': 'application/json',
                'Prefer': 'resolution=ignore-duplicates'
            }
        }
    );
}

function sleep(ms){
    return new Promise(resolve => setTimeout(resolve, ms));
}

function cleanName(name){
    // if(!name) return null;
    // const cleaned = name.trim();
    // if(cleaned.length < 2 || cleaned.length > 200) return null;
    // return cleaned;
    return null;
}

async function scrapePage(url, saved, skipped){
    try{
        const products = await fetchFoods(url);
        if(!products || products.length === 0) return {products: null, saved, skipped};
        const batch = [];

        for (const product of products){
            if(!product.nutriments) {skipped++; continue;}
            const name = cleanName(product.product_name);
            const calories = product.nutriments['energy-kcal_100g'];

            if(!name || !calories || calories <= 0 || calories > 3000){ skipped++; continue;} 

            batch.push({ name, calorie_count: Math.round(calories)});
        }
        if(batch.length > 0){
            await saveIngredients(batch);
            saved += batch.length;
            console.log(`Shranjeno: ${batch.length} živil (skupaj: ${saved}, preskočeno: ${skipped})`);
            
        }
        return{products, saved, skipped};
    } catch (err){
         console.log(`Napaka: `, err.message);
         return {products: [], saved, skipped};
    }
 }

async function main() {
    let saved = 0;
    let skipped = 0;
    console.log('\n=== Zajemam angleska zivila ===');
    for(let page = 1; page <= 80; page++){
        console.log(`Zajemam anglesko stran ${page}...`);
        const url = `https://world.openfoodfacts.org/api/v2/search?page_size=50&page=${page}&fields=product_name,nutriments&sort_by=unique_scans_n`;
        const result = await scrapePage(url, saved, skipped);
        saved = result.saved;
        skipped = result.skipped;
        if(!result.products || result.products.length === 0) break;
        await sleep(2000);
    }
    console.log('\n=== Zajemam slovenska zivila ===');
    for(let page = 1; page <= 80; page++){
        console.log(`Zajemam slovensko stran ${page}...`);
        const url = `https://world.openfoodfacts.org/api/v2/search?countries_tags=slovenia&page_size=50&page=${page}&fields=product_name,nutriments&sort_by=unique_scans_n`;
        const result = await scrapePage(url, saved, skipped);
        saved = result.saved;
        skipped = result.skipped;
        if(!result.products || result.products.length === 0) break;
        await sleep(2000);
    }
    console.log(`\nKoncano! Shranjeno: ${saved}, preskoceno: ${skipped}`);
}

if(require.main == module){
    main();
}

module.exports = {cleanName, fetchFoods, scrapePage};