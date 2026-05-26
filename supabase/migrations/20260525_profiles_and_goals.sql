-- =============================================================================
-- Profiles schema (mobile app: user profile + onboarding body data)
-- =============================================================================
-- Creates the public.profiles table backing the mobile Profile model.
-- Goal-related data lives in public.user_goals (see 20260526_user_goals.sql)
-- and the daily calorie target is stored in public.daily_nutrition_goals.
-- Idempotent: safe to re-run.
-- =============================================================================

set search_path = public;

-- -----------------------------------------------------------------------------
-- 1. Table
-- -----------------------------------------------------------------------------

create table if not exists public.profiles (
    id                   uuid primary key references auth.users(id) on delete cascade,
    email                text,
    username             text unique,
    display_name         text,
    gender               text check (gender in ('male', 'female', 'other')),
    date_of_birth        date,
    height_cm            numeric,
    weight_kg            numeric,
    onboarded_at         timestamptz,
    activity_level       text check (activity_level in
                            ('sedentary', 'light', 'moderate', 'active', 'athlete')),
    target_weight_kg     numeric,
    created_at           timestamptz not null default now(),
    updated_at           timestamptz not null default now()
);

-- Backfill new columns if the table already existed.
alter table public.profiles
    add column if not exists activity_level   text,
    add column if not exists target_weight_kg numeric;

-- Drop legacy goal-related columns now that goals live in user_goals.
alter table public.profiles
    drop column if exists goals,
    drop column if exists weekly_active_minutes,
    drop column if exists weekly_workouts,
    drop column if exists weekly_distance_km;

-- Ensure activity_level check constraint exists when backfilled.
do $$
begin
    if not exists (
        select 1 from information_schema.check_constraints
        where constraint_name = 'profiles_activity_level_check'
    ) then
        alter table public.profiles
            add constraint profiles_activity_level_check
            check (activity_level is null or activity_level in
                ('sedentary', 'light', 'moderate', 'active', 'athlete'));
    end if;
end$$;

-- -----------------------------------------------------------------------------
-- 2. Indexes
-- -----------------------------------------------------------------------------

create index if not exists idx_profiles_username on public.profiles (username);

-- -----------------------------------------------------------------------------
-- 3. Row Level Security
-- -----------------------------------------------------------------------------

alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;

create policy "profiles_select_own"
    on public.profiles for select
    using (id = (select auth.uid()));

create policy "profiles_insert_own"
    on public.profiles for insert
    with check (id = (select auth.uid()));

create policy "profiles_update_own"
    on public.profiles for update
    using (id = (select auth.uid()))
    with check (id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- 4. Triggers
-- -----------------------------------------------------------------------------

-- 4a. Auto-create a profile row whenever a new auth user is created.
create or replace function public.handle_new_user_profile_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.profiles (id, email)
    values (new.id, new.email)
    on conflict (id) do nothing;
    return new;
end;
$$;

drop trigger if exists trg_auth_user_profile_defaults on auth.users;
create trigger trg_auth_user_profile_defaults
    after insert on auth.users
    for each row
    execute function public.handle_new_user_profile_defaults();

-- 4b. Keep updated_at fresh on row updates.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

drop trigger if exists trg_profiles_touch on public.profiles;
create trigger trg_profiles_touch
    before update on public.profiles
    for each row execute function public.touch_updated_at();
