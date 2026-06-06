const {cleanName} = require('./scraper');
const axios = require('axios');

// test 1
describe('cleanName', () => {
    test('vrne null za prazno ime', () => {
        expect(cleanName('')).toBeNull();
        expect(cleanName(null)).toBeNull();
    });
    test('vrne null za prekratko ime', () => {
        expect(cleanName('a')).toBeNull();
    });
    test('vrne null za predolgo ime', () => {
        expect(cleanName('a'.repeat(201))).toBeNull();
    });
    test('obreze presledke', () => {
        expect(cleanName(' mleko ')).toBe('mleko');
    });
    test('vrne pravilno ime', () => {
        expect(cleanName('Mleko')).toBe('Mleko');
    });
});


// test 2
describe('OpenFoodFacts API', () => {
    test('API je dosegljiv', async () => {
        const url = 'https://world.openfoodfacts.org/api/v2/search?page_size=1&fields=product_name';
        try{
        const response = await axios.get(url, {
            headers: { 'User-Agent': 'moceradi-project - Student project - lucija@example.com'},
            timeout: 10000
        });
        expect([200, 503]).toContain(response.status);
    } catch(err){
        expect(err.response.status).toBe(503);
    }
    }, 15000);

    test('API vrne products polje', async () => {
        const url = 'https://world.openfoodfacts.org/api/v2/search?page_size=1&fields=product_name';
        try{
            const response = await axios.get(url, {
                headers: { 'User-Agent': 'moceradi-project - Student project - lucija@example.com'},
                timeout: 10000
            });
            expect(response.data).toHaveProperty('products');
            expect(Array.isArray(response.data.products)).toBe(true);
        }catch(err){
            expect(err.response.status).toBe(503);
        }
    }, 15000);
}); 
