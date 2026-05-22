/* eslint-disable no-console */
require('dotenv').config();
const axios = require('axios');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const USER_AGENT =
  process.env.OFF_USER_AGENT ||
  'health-app-scraper - Student project - hello@example.com';

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('SUPABASE_URL and SUPABASE_SERVICE_KEY must be set in .env');
  process.exit(1);
}

const OFF_FIELDS = [
  'code',
  'product_name',
  'product_name_en',
  'brands',
  'nutriments',
  'quantity',
  'serving_quantity',
  'categories_tags',
  'countries_tags',
  'lang',
  'unique_scans_n',
  'popularity_key',
].join(',');

const BATCH_SIZE = 200;
const REQUEST_DELAY_MS = 1500;
const MAX_RETRIES = 3;
const PAGE_SIZE = 100;

const LIQUID_UNITS = new Set(['ml', 'l', 'cl', 'dl', 'fl', 'floz']);
const BEVERAGE_KEYWORDS = new Set([
  'drink',
  'beverage',
  'juice',
  'soda',
  'cola',
  'water',
  'tea',
  'coffee',
  'milk',
  'smoothie',
  'lemonade',
  'shake',
  'nectar',
  'tonic',
  'cider',
  'beer',
  'lager',
  'ale',
  'wine',
  'champagne',
  'kombucha',
  'sok',
  'sokovi',
  'pijaca',
  'pijaco',
  'pijace',
  'voda',
  'nektar',
  'gazirana',
  'gazirano',
  'napitak',
  'napoj',
  'caj',
  'kava',
  'mleko',
  'pivo',
  'vino',
  'limonada',
]);

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function toNumber(value) {
  if (value === null || value === undefined) return null;
  const n = typeof value === 'number' ? value : parseFloat(String(value).replace(',', '.'));
  return Number.isFinite(n) ? n : null;
}

function firstBrand(brands) {
  if (!brands) return null;
  if (Array.isArray(brands)) {
    for (const b of brands) {
      const s = (b || '').toString().trim();
      if (s) return s;
    }
    return null;
  }
  const first = String(brands).split(',')[0].trim();
  return first || null;
}

function kcalPer100(nutriments) {
  if (!nutriments) return null;
  const kcal = toNumber(nutriments['energy-kcal_100g']);
  if (kcal !== null) return kcal;
  const kj =
    toNumber(nutriments['energy-kj_100g']) ?? toNumber(nutriments['energy_100g']);
  return kj !== null ? kj * 0.239 : null;
}

function quantityLooksLiquid(quantity) {
  if (!quantity) return false;
  const lower = String(quantity).toLowerCase().replace(/\s+/g, '');
  const match = lower.match(/([a-z]+)$/);
  if (!match) return false;
  return LIQUID_UNITS.has(match[1]);
}

function nameLooksLikeBeverage(name) {
  if (!name) return false;
  const tokens = String(name)
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter(Boolean);
  return tokens.some((t) => BEVERAGE_KEYWORDS.has(t));
}

function detectBeverage(product, name) {
  const tags = product.categories_tags;
  if (Array.isArray(tags) && tags.includes('en:beverages')) return true;
  if (quantityLooksLiquid(product.quantity)) return true;
  if (nameLooksLikeBeverage(name)) return true;
  return false;
}

function pickName(product) {
  const candidates = [product.product_name, product.product_name_en];
  for (const c of candidates) {
    const s = (c || '').toString().trim();
    if (s) return s;
  }
  return null;
}

function pickCountries(product) {
  const raw = product.countries_tags;
  if (!Array.isArray(raw)) return [];
  return raw
    .map((t) => (typeof t === 'string' ? t.trim() : ''))
    .filter((t) => t.length > 0);
}

function productToRow(product) {
  const name = pickName(product);
  if (!name) return null;
  const kcal = kcalPer100(product.nutriments);
  if (kcal === null) return null;

  return {
    barcode: product.code ? String(product.code).trim() : null,
    name,
    brand: firstBrand(product.brands),
    is_beverage: detectBeverage(product, name),
    default_serving_grams: toNumber(product.serving_quantity),
    kcal_per_100g: kcal,
    protein_per_100g: toNumber(product.nutriments?.proteins_100g) ?? 0,
    carbs_per_100g: toNumber(product.nutriments?.carbohydrates_100g) ?? 0,
    fat_per_100g: toNumber(product.nutriments?.fat_100g) ?? 0,
    sugar_per_100g: toNumber(product.nutriments?.sugars_100g) ?? 0,
    popularity: toNumber(product.unique_scans_n) ?? 0,
    countries: pickCountries(product),
    language: product.lang || null,
    source: 'off',
  };
}

async function fetchPage({ url, params, attempt = 1 }) {
  try {
    const res = await axios.get(url, {
      params,
      headers: { 'User-Agent': USER_AGENT },
      timeout: 20000,
    });
    return res.data;
  } catch (err) {
    if (attempt >= MAX_RETRIES) throw err;
    const wait = 2000 * attempt;
    console.warn(`  retry ${attempt + 1}/${MAX_RETRIES} after ${wait}ms — ${err.message}`);
    await sleep(wait);
    return fetchPage({ url, params, attempt: attempt + 1 });
  }
}

async function fetchOffPage({ source, page }) {
  const url = 'https://world.openfoodfacts.org/cgi/search.pl';
  const params = {
    action: 'process',
    json: 1,
    page_size: PAGE_SIZE,
    page,
    sort_by: 'unique_scans_n',
    fields: OFF_FIELDS,
  };
  if (source === 'slovenia') {
    params.tagtype_0 = 'countries';
    params.tag_contains_0 = 'contains';
    params.tag_0 = 'slovenia';
  }
  return fetchPage({ url, params });
}

async function upsertBatch(rows) {
  if (rows.length === 0) return;

  // Split into rows with barcode (upsert on barcode) and rows without (insert as new).
  const withBarcode = rows.filter((r) => r.barcode);
  const withoutBarcode = rows.filter((r) => !r.barcode);

  if (withBarcode.length > 0) {
    await axios.post(`${SUPABASE_URL}/rest/v1/popular_foods`, withBarcode, {
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json',
        Prefer: 'resolution=merge-duplicates,return=minimal',
      },
      params: { on_conflict: 'barcode' },
      timeout: 30000,
    });
  }
  if (withoutBarcode.length > 0) {
    await axios.post(`${SUPABASE_URL}/rest/v1/popular_foods`, withoutBarcode, {
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal',
      },
      timeout: 30000,
    });
  }
}

async function ingestSource({ source, pages }) {
  console.log(`\n=== Ingesting ${source} (up to ${pages * PAGE_SIZE} products) ===`);
  let buffer = [];
  let saved = 0;
  let skipped = 0;
  const seenBarcodes = new Set();

  for (let page = 1; page <= pages; page++) {
    let data;
    try {
      data = await fetchOffPage({ source, page });
    } catch (err) {
      console.warn(`  page ${page} failed permanently — skipping (${err.message})`);
      continue;
    }
    const products = data?.products || [];
    if (products.length === 0) {
      console.log(`  page ${page}: empty → stopping early`);
      break;
    }

    for (const product of products) {
      const row = productToRow(product);
      if (!row) {
        skipped += 1;
        continue;
      }
      if (row.barcode) {
        if (seenBarcodes.has(row.barcode)) continue;
        seenBarcodes.add(row.barcode);
      }
      buffer.push(row);
      if (buffer.length >= BATCH_SIZE) {
        try {
          await upsertBatch(buffer);
          saved += buffer.length;
        } catch (err) {
          console.warn(`  upsert batch failed — ${err.message}`);
        }
        buffer = [];
      }
    }
    console.log(`  page ${page}: ${products.length} products | saved=${saved} skipped=${skipped}`);
    await sleep(REQUEST_DELAY_MS);
  }

  if (buffer.length > 0) {
    try {
      await upsertBatch(buffer);
      saved += buffer.length;
    } catch (err) {
      console.warn(`  final upsert batch failed — ${err.message}`);
    }
  }

  console.log(`=== ${source} done: saved=${saved} skipped=${skipped} ===`);
  return saved;
}

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = {
    slovenia: false,
    global: false,
    sloveniaPages: 200, // up to 20k Slovenia-tagged products
    globalPages: 150, // up to 15k globally popular products
  };
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--slovenia') opts.slovenia = true;
    else if (arg === '--global') opts.global = true;
    else if (arg === '--slovenia-pages') opts.sloveniaPages = parseInt(args[++i], 10) || opts.sloveniaPages;
    else if (arg === '--global-pages') opts.globalPages = parseInt(args[++i], 10) || opts.globalPages;
  }
  if (!opts.slovenia && !opts.global) {
    opts.slovenia = true;
    opts.global = true;
  }
  return opts;
}

async function main() {
  const opts = parseArgs();
  console.log('Config:', opts);

  if (opts.slovenia) {
    await ingestSource({ source: 'slovenia', pages: opts.sloveniaPages });
  }
  if (opts.global) {
    await ingestSource({ source: 'global', pages: opts.globalPages });
  }

  console.log('\nAll done.');
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
