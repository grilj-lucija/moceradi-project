/* eslint-disable no-console */
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('SUPABASE_URL and SUPABASE_SERVICE_KEY must be set in .env');
  process.exit(1);
}

const DATA_PATH = path.join(__dirname, 'data', 'generic_foods.json');
const BATCH_SIZE = 100;

function parseArgs() {
  const args = process.argv.slice(2);
  return {
    reset: args.includes('--reset'),
    file: (() => {
      const i = args.indexOf('--file');
      return i >= 0 ? args[i + 1] : DATA_PATH;
    })(),
  };
}

function rowFromItem(item) {
  if (!item.slug || !item.name) {
    throw new Error(`Item missing slug or name: ${JSON.stringify(item)}`);
  }
  return {
    slug: item.slug,
    name: item.name,
    category: item.category ?? null,
    is_beverage: item.is_beverage === true,
    default_serving_grams: item.default_serving_grams ?? null,
    kcal_per_100g: Number(item.kcal_per_100g ?? 0),
    protein_per_100g: Number(item.protein_per_100g ?? 0),
    carbs_per_100g: Number(item.carbs_per_100g ?? 0),
    fat_per_100g: Number(item.fat_per_100g ?? 0),
    sugar_per_100g: Number(item.sugar_per_100g ?? 0),
    priority: Number(item.priority ?? 0),
    source: 'curated',
  };
}

async function resetCuratedRows() {
  console.log('Deleting existing rows with source=curated…');
  await axios.delete(`${SUPABASE_URL}/rest/v1/generic_foods`, {
    params: { source: 'eq.curated' },
    headers: {
      apikey: SUPABASE_SERVICE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      Prefer: 'return=minimal',
    },
    timeout: 30000,
  });
}

async function upsertBatch(rows) {
  if (rows.length === 0) return;
  await axios.post(`${SUPABASE_URL}/rest/v1/generic_foods`, rows, {
    headers: {
      apikey: SUPABASE_SERVICE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'resolution=merge-duplicates,return=minimal',
    },
    params: { on_conflict: 'slug' },
    timeout: 30000,
  });
}

async function main() {
  const opts = parseArgs();
  if (!fs.existsSync(opts.file)) {
    console.error(`File not found: ${opts.file}`);
    process.exit(1);
  }

  const raw = JSON.parse(fs.readFileSync(opts.file, 'utf8'));
  const items = raw.items || [];
  console.log(`Loaded ${items.length} items from ${opts.file}`);

  const rows = items.map(rowFromItem);

  // Sanity check: no duplicate slugs.
  const slugs = new Set();
  for (const r of rows) {
    if (slugs.has(r.slug)) throw new Error(`Duplicate slug: ${r.slug}`);
    slugs.add(r.slug);
  }

  if (opts.reset) await resetCuratedRows();

  let saved = 0;
  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    const batch = rows.slice(i, i + BATCH_SIZE);
    try {
      await upsertBatch(batch);
      saved += batch.length;
      console.log(`  upserted ${saved}/${rows.length}`);
    } catch (err) {
      console.error(`  batch failed at ${i}: ${err.message}`);
      if (err.response?.data) console.error(err.response.data);
    }
  }

  console.log(`\nDone. saved=${saved}/${rows.length}`);
}

main().catch((err) => {
  console.error('Fatal error:', err.message);
  if (err.response?.data) console.error(err.response.data);
  process.exit(1);
});
