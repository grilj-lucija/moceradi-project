-- =============================================================================
-- Allow 'generic' as a valid food_source value
-- =============================================================================
-- The 20260520 schema only permitted ('open_food_facts', 'custom', 'recipe').
-- 20260522 introduced the generic_foods catalog whose rows are mapped to
-- FoodSourceKind.generic ('generic') in the mobile app, so logging any popular
-- catalog food fails with check constraint "food_entries_food_source_check".
-- This migration relaxes the constraint on food_entries, recent_foods and
-- recipe_ingredients. Idempotent.
-- =============================================================================

set search_path = public;

alter table public.food_entries
    drop constraint if exists food_entries_food_source_check;

alter table public.food_entries
    add constraint food_entries_food_source_check
    check (food_source in ('open_food_facts', 'generic', 'custom', 'recipe'));

alter table public.recent_foods
    drop constraint if exists recent_foods_food_source_check;

alter table public.recent_foods
    add constraint recent_foods_food_source_check
    check (food_source in ('open_food_facts', 'generic', 'custom', 'recipe'));

alter table public.recipe_ingredients
    drop constraint if exists recipe_ingredients_food_source_check;

alter table public.recipe_ingredients
    add constraint recipe_ingredients_food_source_check
    check (food_source in ('open_food_facts', 'generic', 'custom', 'recipe'));
