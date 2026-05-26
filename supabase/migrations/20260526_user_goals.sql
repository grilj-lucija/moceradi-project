-- =============================================================================
-- User goals schema (intents + primary weekly activity goal + pace preference)
-- =============================================================================
-- 1-to-1 with auth.users. The daily calorie target itself lives in
-- public.daily_nutrition_goals.kcal; the `kcal_override` flag here tracks
-- whether the user has manually adjusted away from the engine's recommendation.
-- Idempotent: safe to re-run.
-- =============================================================================

set search_path = public;

-- -----------------------------------------------------------------------------
-- 1. Table
-- -----------------------------------------------------------------------------

create table if not exists public.user_goals (
    user_id          uuid primary key references auth.users(id) on delete cascade,
    intents          text[] not null default '{}',
    activity_metric  text check (activity_metric in (
                        'cycling_distance',
                        'running_distance',
                        'walking_distance',
                        'active_minutes',
                        'calories_burned',
                        'workouts'
                    )),
    activity_target  numeric,
    activity_period  text not null default 'week'
                        check (activity_period in ('day', 'week', 'month')),
    pace             text not null default 'balanced'
                        check (pace in ('easy', 'balanced', 'aggressive')),
    kcal_override    boolean not null default false,
    created_at       timestamptz not null default now(),
    updated_at       timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 2. Row Level Security
-- -----------------------------------------------------------------------------

alter table public.user_goals enable row level security;

drop policy if exists "user_goals_select_own" on public.user_goals;
drop policy if exists "user_goals_insert_own" on public.user_goals;
drop policy if exists "user_goals_update_own" on public.user_goals;

create policy "user_goals_select_own"
    on public.user_goals for select
    using (user_id = (select auth.uid()));

create policy "user_goals_insert_own"
    on public.user_goals for insert
    with check (user_id = (select auth.uid()));

create policy "user_goals_update_own"
    on public.user_goals for update
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- 3. Triggers
-- -----------------------------------------------------------------------------

-- 3a. Auto-create an empty row whenever a new auth user is created.
create or replace function public.handle_new_user_goals_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.user_goals (user_id)
    values (new.id)
    on conflict (user_id) do nothing;
    return new;
end;
$$;

drop trigger if exists trg_auth_user_goals_defaults on auth.users;
create trigger trg_auth_user_goals_defaults
    after insert on auth.users
    for each row
    execute function public.handle_new_user_goals_defaults();

-- 3b. Keep updated_at fresh on row updates.
drop trigger if exists trg_user_goals_touch on public.user_goals;
create trigger trg_user_goals_touch
    before update on public.user_goals
    for each row execute function public.touch_updated_at();

-- -----------------------------------------------------------------------------
-- 4. Backfill rows for users that already exist.
-- -----------------------------------------------------------------------------

insert into public.user_goals (user_id)
select id from auth.users
on conflict (user_id) do nothing;
