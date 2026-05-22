-- =============================================================================
-- Generic foods: switch from raw USDA dump to hand-curated catalog
-- =============================================================================
-- Adds a stable `slug` identifier (consumer-friendly) and removes the messy
-- SR-Legacy rows that were imported earlier. Re-seed via `npm run seed` in
-- the scraper directory.
-- =============================================================================

set search_path = public;

-- Wipe any data imported from the previous USDA dump pipeline.
delete from public.generic_foods
where source in ('usda_sr_legacy', 'usda_foundation', 'usda_fndds');

alter table public.generic_foods
    add column if not exists slug text;

update public.generic_foods
    set slug = id::text
    where slug is null;

alter table public.generic_foods
    alter column slug set not null;

create unique index if not exists idx_generic_foods_slug
    on public.generic_foods (slug);
