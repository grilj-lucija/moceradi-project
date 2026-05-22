-- =============================================================================
-- Nutrition schema (mobile app: custom foods, recipes, food log, daily goals)
-- =============================================================================
-- Replaces the legacy `dish` / `ingredient` / `meal` tables.
-- Activities-related tables are intentionally untouched.
-- Idempotent: safe to re-run.
-- =============================================================================

set search_path = public;

-- -----------------------------------------------------------------------------
-- 1. Drop legacy nutrition tables (empty per pg_dump)
-- -----------------------------------------------------------------------------

drop table if exists public.meal cascade;
drop table if exists public.dish_has_ingredient cascade;
drop table if exists public.dish cascade;
drop table if exists public.ingredient cascade;

-- -----------------------------------------------------------------------------
-- 2. Tables
-- -----------------------------------------------------------------------------

create table if not exists public.custom_foods (
    id                       uuid primary key default gen_random_uuid(),
    user_id                  uuid not null references auth.users(id) on delete cascade,
    name                     text not null,
    brand                    text,
    is_beverage              boolean not null default false,
    default_serving_grams    numeric,
    kcal_per_100g            numeric not null default 0,
    protein_per_100g         numeric not null default 0,
    carbs_per_100g           numeric not null default 0,
    fat_per_100g             numeric not null default 0,
    sugar_per_100g           numeric not null default 0,
    created_at               timestamptz not null default now(),
    updated_at               timestamptz not null default now()
);

create table if not exists public.recipes (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null references auth.users(id) on delete cascade,
    name        text not null,
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now()
);

create table if not exists public.recipe_ingredients (
    id                              uuid primary key default gen_random_uuid(),
    recipe_id                       uuid not null references public.recipes(id) on delete cascade,
    position                        integer not null default 0,
    grams                           numeric not null check (grams > 0),
    food_external_id                text not null,
    food_name                       text not null,
    food_brand                      text,
    food_source                     text not null check (food_source in ('open_food_facts', 'custom', 'recipe')),
    food_is_beverage                boolean not null default false,
    food_default_serving_grams      numeric,
    food_kcal_per_100g              numeric not null default 0,
    food_protein_per_100g           numeric not null default 0,
    food_carbs_per_100g             numeric not null default 0,
    food_fat_per_100g               numeric not null default 0,
    food_sugar_per_100g             numeric not null default 0
);

create table if not exists public.food_entries (
    id                              uuid primary key default gen_random_uuid(),
    user_id                         uuid not null references auth.users(id) on delete cascade,
    logged_at                       timestamptz not null default now(),
    meal_slot                       text not null check (meal_slot in ('breakfast', 'lunch', 'dinner', 'snack')),
    grams                           numeric not null check (grams > 0),
    food_external_id                text not null,
    food_name                       text not null,
    food_brand                      text,
    food_source                     text not null check (food_source in ('open_food_facts', 'custom', 'recipe')),
    food_is_beverage                boolean not null default false,
    food_default_serving_grams      numeric,
    food_kcal_per_100g              numeric not null default 0,
    food_protein_per_100g           numeric not null default 0,
    food_carbs_per_100g             numeric not null default 0,
    food_fat_per_100g               numeric not null default 0,
    food_sugar_per_100g             numeric not null default 0,
    created_at                      timestamptz not null default now()
);

create table if not exists public.daily_nutrition_goals (
    user_id        uuid primary key references auth.users(id) on delete cascade,
    kcal           numeric not null default 2400,
    protein_grams  numeric not null default 150,
    carbs_grams    numeric not null default 280,
    fat_grams      numeric not null default 75,
    sugar_grams    numeric not null default 50,
    liquids_ml     numeric not null default 2500,
    updated_at     timestamptz not null default now()
);

create table if not exists public.recent_foods (
    user_id                         uuid not null references auth.users(id) on delete cascade,
    food_external_id                text not null,
    food_name                       text not null,
    food_brand                      text,
    food_source                     text not null check (food_source in ('open_food_facts', 'custom', 'recipe')),
    food_is_beverage                boolean not null default false,
    food_default_serving_grams      numeric,
    food_kcal_per_100g              numeric not null default 0,
    food_protein_per_100g           numeric not null default 0,
    food_carbs_per_100g             numeric not null default 0,
    food_fat_per_100g               numeric not null default 0,
    food_sugar_per_100g             numeric not null default 0,
    last_logged_at                  timestamptz not null default now(),
    primary key (user_id, food_external_id)
);

-- -----------------------------------------------------------------------------
-- 3. Indexes
-- -----------------------------------------------------------------------------

create index if not exists idx_food_entries_user_logged_at
    on public.food_entries (user_id, logged_at desc);

create index if not exists idx_recent_foods_user_last_logged_at
    on public.recent_foods (user_id, last_logged_at desc);

create index if not exists idx_custom_foods_user_name
    on public.custom_foods (user_id, name);

create index if not exists idx_recipes_user_name
    on public.recipes (user_id, name);

create index if not exists idx_recipe_ingredients_recipe_position
    on public.recipe_ingredients (recipe_id, position);

-- -----------------------------------------------------------------------------
-- 4. Row Level Security
-- -----------------------------------------------------------------------------

alter table public.custom_foods            enable row level security;
alter table public.recipes                 enable row level security;
alter table public.recipe_ingredients      enable row level security;
alter table public.food_entries            enable row level security;
alter table public.daily_nutrition_goals   enable row level security;
alter table public.recent_foods            enable row level security;

-- custom_foods --------------------------------------------------------------
drop policy if exists "custom_foods_select_own"  on public.custom_foods;
drop policy if exists "custom_foods_insert_own"  on public.custom_foods;
drop policy if exists "custom_foods_update_own"  on public.custom_foods;
drop policy if exists "custom_foods_delete_own"  on public.custom_foods;

create policy "custom_foods_select_own"
    on public.custom_foods for select
    using (user_id = (select auth.uid()));

create policy "custom_foods_insert_own"
    on public.custom_foods for insert
    with check (user_id = (select auth.uid()));

create policy "custom_foods_update_own"
    on public.custom_foods for update
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

create policy "custom_foods_delete_own"
    on public.custom_foods for delete
    using (user_id = (select auth.uid()));

-- recipes -------------------------------------------------------------------
drop policy if exists "recipes_select_own" on public.recipes;
drop policy if exists "recipes_insert_own" on public.recipes;
drop policy if exists "recipes_update_own" on public.recipes;
drop policy if exists "recipes_delete_own" on public.recipes;

create policy "recipes_select_own"
    on public.recipes for select
    using (user_id = (select auth.uid()));

create policy "recipes_insert_own"
    on public.recipes for insert
    with check (user_id = (select auth.uid()));

create policy "recipes_update_own"
    on public.recipes for update
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

create policy "recipes_delete_own"
    on public.recipes for delete
    using (user_id = (select auth.uid()));

-- recipe_ingredients (scope via parent recipe ownership) --------------------
drop policy if exists "recipe_ingredients_select_own" on public.recipe_ingredients;
drop policy if exists "recipe_ingredients_insert_own" on public.recipe_ingredients;
drop policy if exists "recipe_ingredients_update_own" on public.recipe_ingredients;
drop policy if exists "recipe_ingredients_delete_own" on public.recipe_ingredients;

create policy "recipe_ingredients_select_own"
    on public.recipe_ingredients for select
    using (
        exists (
            select 1 from public.recipes r
            where r.id = recipe_ingredients.recipe_id
              and r.user_id = (select auth.uid())
        )
    );

create policy "recipe_ingredients_insert_own"
    on public.recipe_ingredients for insert
    with check (
        exists (
            select 1 from public.recipes r
            where r.id = recipe_ingredients.recipe_id
              and r.user_id = (select auth.uid())
        )
    );

create policy "recipe_ingredients_update_own"
    on public.recipe_ingredients for update
    using (
        exists (
            select 1 from public.recipes r
            where r.id = recipe_ingredients.recipe_id
              and r.user_id = (select auth.uid())
        )
    )
    with check (
        exists (
            select 1 from public.recipes r
            where r.id = recipe_ingredients.recipe_id
              and r.user_id = (select auth.uid())
        )
    );

create policy "recipe_ingredients_delete_own"
    on public.recipe_ingredients for delete
    using (
        exists (
            select 1 from public.recipes r
            where r.id = recipe_ingredients.recipe_id
              and r.user_id = (select auth.uid())
        )
    );

-- food_entries --------------------------------------------------------------
drop policy if exists "food_entries_select_own" on public.food_entries;
drop policy if exists "food_entries_insert_own" on public.food_entries;
drop policy if exists "food_entries_update_own" on public.food_entries;
drop policy if exists "food_entries_delete_own" on public.food_entries;

create policy "food_entries_select_own"
    on public.food_entries for select
    using (user_id = (select auth.uid()));

create policy "food_entries_insert_own"
    on public.food_entries for insert
    with check (user_id = (select auth.uid()));

create policy "food_entries_update_own"
    on public.food_entries for update
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

create policy "food_entries_delete_own"
    on public.food_entries for delete
    using (user_id = (select auth.uid()));

-- daily_nutrition_goals -----------------------------------------------------
drop policy if exists "daily_nutrition_goals_select_own" on public.daily_nutrition_goals;
drop policy if exists "daily_nutrition_goals_insert_own" on public.daily_nutrition_goals;
drop policy if exists "daily_nutrition_goals_update_own" on public.daily_nutrition_goals;

create policy "daily_nutrition_goals_select_own"
    on public.daily_nutrition_goals for select
    using (user_id = (select auth.uid()));

create policy "daily_nutrition_goals_insert_own"
    on public.daily_nutrition_goals for insert
    with check (user_id = (select auth.uid()));

create policy "daily_nutrition_goals_update_own"
    on public.daily_nutrition_goals for update
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

-- recent_foods --------------------------------------------------------------
drop policy if exists "recent_foods_select_own" on public.recent_foods;
drop policy if exists "recent_foods_delete_own" on public.recent_foods;

create policy "recent_foods_select_own"
    on public.recent_foods for select
    using (user_id = (select auth.uid()));

create policy "recent_foods_delete_own"
    on public.recent_foods for delete
    using (user_id = (select auth.uid()));

-- recent_foods inserts/updates happen via the trigger function only.

-- -----------------------------------------------------------------------------
-- 5. Triggers
-- -----------------------------------------------------------------------------

-- 5a. Create a default daily goal whenever a new auth user is created.
create or replace function public.handle_new_user_nutrition_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.daily_nutrition_goals (user_id)
    values (new.id)
    on conflict (user_id) do nothing;
    return new;
end;
$$;

drop trigger if exists trg_auth_user_nutrition_defaults on auth.users;
create trigger trg_auth_user_nutrition_defaults
    after insert on auth.users
    for each row
    execute function public.handle_new_user_nutrition_defaults();

-- 5b. On each food_entries insert, upsert the food into recent_foods.
create or replace function public.handle_food_entry_recent_cache()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.recent_foods (
        user_id, food_external_id, food_name, food_brand, food_source,
        food_is_beverage, food_default_serving_grams,
        food_kcal_per_100g, food_protein_per_100g, food_carbs_per_100g,
        food_fat_per_100g, food_sugar_per_100g, last_logged_at
    ) values (
        new.user_id, new.food_external_id, new.food_name, new.food_brand, new.food_source,
        new.food_is_beverage, new.food_default_serving_grams,
        new.food_kcal_per_100g, new.food_protein_per_100g, new.food_carbs_per_100g,
        new.food_fat_per_100g, new.food_sugar_per_100g, new.logged_at
    )
    on conflict (user_id, food_external_id) do update set
        food_name                  = excluded.food_name,
        food_brand                 = excluded.food_brand,
        food_source                = excluded.food_source,
        food_is_beverage           = excluded.food_is_beverage,
        food_default_serving_grams = excluded.food_default_serving_grams,
        food_kcal_per_100g         = excluded.food_kcal_per_100g,
        food_protein_per_100g      = excluded.food_protein_per_100g,
        food_carbs_per_100g        = excluded.food_carbs_per_100g,
        food_fat_per_100g          = excluded.food_fat_per_100g,
        food_sugar_per_100g        = excluded.food_sugar_per_100g,
        last_logged_at             = greatest(public.recent_foods.last_logged_at, excluded.last_logged_at);
    return new;
end;
$$;

drop trigger if exists trg_food_entry_recent_cache on public.food_entries;
create trigger trg_food_entry_recent_cache
    after insert on public.food_entries
    for each row
    execute function public.handle_food_entry_recent_cache();

-- 5c. Keep updated_at fresh on row updates.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

drop trigger if exists trg_custom_foods_touch on public.custom_foods;
create trigger trg_custom_foods_touch
    before update on public.custom_foods
    for each row execute function public.touch_updated_at();

drop trigger if exists trg_recipes_touch on public.recipes;
create trigger trg_recipes_touch
    before update on public.recipes
    for each row execute function public.touch_updated_at();

drop trigger if exists trg_daily_goals_touch on public.daily_nutrition_goals;
create trigger trg_daily_goals_touch
    before update on public.daily_nutrition_goals
    for each row execute function public.touch_updated_at();
