-- =============================================================================
-- Shared popular foods catalog (scraped from Open Food Facts)
-- =============================================================================
-- Read-only for end users; writeable only by service_role (scraper).
-- =============================================================================

set search_path = public;

create extension if not exists pg_trgm with schema public;

-- -----------------------------------------------------------------------------
-- 1. Table
-- -----------------------------------------------------------------------------

create table if not exists public.popular_foods (
    id                       uuid primary key default gen_random_uuid(),
    barcode                  text unique,
    name                     text not null,
    brand                    text,
    is_beverage              boolean not null default false,
    default_serving_grams    numeric,
    kcal_per_100g            numeric not null,
    protein_per_100g         numeric not null default 0,
    carbs_per_100g           numeric not null default 0,
    fat_per_100g             numeric not null default 0,
    sugar_per_100g           numeric not null default 0,
    popularity               integer not null default 0,
    countries                text[] not null default array[]::text[],
    language                 text,
    source                   text not null default 'off',
    source_payload           jsonb,
    created_at               timestamptz not null default now(),
    updated_at               timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 2. Indexes
-- -----------------------------------------------------------------------------

create index if not exists idx_popular_foods_name_trgm
    on public.popular_foods using gin (lower(name) gin_trgm_ops);

create index if not exists idx_popular_foods_brand_trgm
    on public.popular_foods using gin (lower(coalesce(brand, '')) gin_trgm_ops);

create index if not exists idx_popular_foods_popularity
    on public.popular_foods (popularity desc);

create index if not exists idx_popular_foods_countries_gin
    on public.popular_foods using gin (countries);

-- -----------------------------------------------------------------------------
-- 3. RLS: read-only for everyone, write only via service_role
-- -----------------------------------------------------------------------------

alter table public.popular_foods enable row level security;

drop policy if exists "popular_foods_read_public" on public.popular_foods;
create policy "popular_foods_read_public"
    on public.popular_foods for select
    to anon, authenticated
    using (true);

-- service_role bypasses RLS automatically, so no insert/update policies needed.
-- No insert/update/delete policies for anon or authenticated = writes are blocked.

-- -----------------------------------------------------------------------------
-- 4. updated_at touch trigger (reuses helper from nutrition migration if loaded)
-- -----------------------------------------------------------------------------

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

drop trigger if exists trg_popular_foods_touch on public.popular_foods;
create trigger trg_popular_foods_touch
    before update on public.popular_foods
    for each row execute function public.touch_updated_at();
