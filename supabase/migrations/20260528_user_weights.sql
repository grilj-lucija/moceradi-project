-- =============================================================================
-- Weekly weight tracking (mobile app: per-week weight check-ins)
-- =============================================================================
-- Stores one weight entry per user per ISO week (Monday-anchored).
-- A trigger mirrors the most-recent entry into profiles.weight_kg so that
-- WeightProgressCard and CalorieEngine keep working without app changes.
-- Idempotent: safe to re-run.
-- =============================================================================

set search_path = public;

-- -----------------------------------------------------------------------------
-- 1. Table
-- -----------------------------------------------------------------------------

create table if not exists public.user_weights (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null references public.profiles(id) on delete cascade,
    weight_kg   numeric not null check (weight_kg > 0 and weight_kg < 500),
    logged_at   timestamptz not null default now(),
    week_start  date not null,
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now(),
    constraint user_weights_unique_week unique (user_id, week_start),
    constraint user_weights_week_is_monday check (extract(isodow from week_start) = 1)
);

-- -----------------------------------------------------------------------------
-- 2. Indexes
-- -----------------------------------------------------------------------------

create index if not exists idx_user_weights_user_week
    on public.user_weights (user_id, week_start desc);

-- -----------------------------------------------------------------------------
-- 3. Row Level Security
-- -----------------------------------------------------------------------------

alter table public.user_weights enable row level security;

drop policy if exists "user_weights_select_own" on public.user_weights;
drop policy if exists "user_weights_insert_own" on public.user_weights;
drop policy if exists "user_weights_update_own" on public.user_weights;
drop policy if exists "user_weights_delete_own" on public.user_weights;

create policy "user_weights_select_own"
    on public.user_weights for select
    using (user_id = (select auth.uid()));

create policy "user_weights_insert_own"
    on public.user_weights for insert
    with check (user_id = (select auth.uid()));

create policy "user_weights_update_own"
    on public.user_weights for update
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

create policy "user_weights_delete_own"
    on public.user_weights for delete
    using (user_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- 4. Triggers
-- -----------------------------------------------------------------------------

-- 4a. Keep updated_at fresh on row updates.
drop trigger if exists trg_user_weights_touch on public.user_weights;
create trigger trg_user_weights_touch
    before update on public.user_weights
    for each row execute function public.touch_updated_at();

-- 4b. Mirror the most-recent weight into profiles.weight_kg.
create or replace function public.sync_profile_weight_from_user_weights()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    latest_week date;
begin
    select max(week_start) into latest_week
    from public.user_weights
    where user_id = new.user_id;

    if latest_week is null or new.week_start >= latest_week then
        update public.profiles
        set weight_kg = new.weight_kg
        where id = new.user_id;
    end if;

    return new;
end;
$$;

drop trigger if exists trg_user_weights_sync_profile on public.user_weights;
create trigger trg_user_weights_sync_profile
    after insert or update of weight_kg, week_start on public.user_weights
    for each row execute function public.sync_profile_weight_from_user_weights();
