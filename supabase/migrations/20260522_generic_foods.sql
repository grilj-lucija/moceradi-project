-- =============================================================================
-- Generic foods catalog (USDA FoodData Central — SR Legacy)
-- =============================================================================
-- Read-only for end users; writeable only by service_role (importer script).
-- This is the catalog that backs manual text search ("apple", "skyr", "carrot").
-- =============================================================================

set search_path = public;

create extension if not exists pg_trgm with schema public;

-- -----------------------------------------------------------------------------
-- 1. Table
-- -----------------------------------------------------------------------------

create table if not exists public.generic_foods (
    id                       uuid primary key default gen_random_uuid(),
    fdc_id                   bigint unique,
    name                     text not null,
    category                 text,
    is_beverage              boolean not null default false,
    default_serving_grams    numeric,
    kcal_per_100g            numeric not null,
    protein_per_100g         numeric not null default 0,
    carbs_per_100g           numeric not null default 0,
    fat_per_100g             numeric not null default 0,
    sugar_per_100g           numeric not null default 0,
    priority                 integer not null default 0,
    source                   text not null default 'usda_sr_legacy',
    source_payload           jsonb,
    created_at               timestamptz not null default now(),
    updated_at               timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 2. Indexes
-- -----------------------------------------------------------------------------

create index if not exists idx_generic_foods_name_trgm
    on public.generic_foods using gin (lower(name) gin_trgm_ops);

create index if not exists idx_generic_foods_priority
    on public.generic_foods (priority desc, char_length(name) asc);

create index if not exists idx_generic_foods_category
    on public.generic_foods (category);

-- -----------------------------------------------------------------------------
-- 3. RLS: read-only for everyone, writes only via service_role
-- -----------------------------------------------------------------------------

alter table public.generic_foods enable row level security;

drop policy if exists "generic_foods_read_public" on public.generic_foods;
create policy "generic_foods_read_public"
    on public.generic_foods for select
    to anon, authenticated
    using (true);

-- service_role bypasses RLS automatically; no insert/update/delete policies on
-- purpose so anon/authenticated cannot mutate the catalog.

-- -----------------------------------------------------------------------------
-- 4. updated_at trigger (function is created by 20260520_nutrition_schema.sql)
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

drop trigger if exists trg_generic_foods_touch on public.generic_foods;
create trigger trg_generic_foods_touch
    before update on public.generic_foods
    for each row execute function public.touch_updated_at();
