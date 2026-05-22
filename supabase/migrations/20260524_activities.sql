-- =============================================================================
-- Activities schema (workouts: walking, running, cycling)
-- Strava-style split: summary row per activity + lazy-loaded full streams.
-- Legacy `walk` / `walk_node` tables are intentionally left untouched.
-- Idempotent: safe to re-run.
-- =============================================================================

set search_path = public;

-- -----------------------------------------------------------------------------
-- 1. Tables
-- -----------------------------------------------------------------------------

create table if not exists public.activities (
    id                      uuid primary key default gen_random_uuid(),
    user_id                 uuid not null references auth.users(id) on delete cascade,
    type                    text not null check (type in ('walking', 'running', 'cycling')),
    title                   text,
    description             text,

    started_at              timestamptz not null,
    ended_at                timestamptz,
    duration_seconds        integer not null,
    moving_seconds          integer,

    distance_meters         double precision not null default 0,
    elevation_gain_meters   double precision,
    elevation_loss_meters   double precision,

    avg_heart_rate          integer,
    max_heart_rate          integer,
    avg_pace_s_per_km       double precision,
    max_speed_mps           double precision,
    calories_kcal           double precision,
    weight_kg               double precision,

    start_lat               double precision,
    start_lng               double precision,
    end_lat                 double precision,
    end_lng                 double precision,
    bounds                  jsonb,
    summary_polyline        text,

    laps                    jsonb,

    source                  text not null default 'workout',
    visibility              text not null default 'private'
                               check (visibility in ('private', 'followers', 'public')),
    external_id             text,

    created_at              timestamptz not null default now(),
    updated_at              timestamptz not null default now()
);

create table if not exists public.activity_streams (
    activity_id      uuid primary key references public.activities(id) on delete cascade,
    time_offsets_ms  integer[]          not null,
    lats             double precision[] not null,
    lngs             double precision[] not null,
    altitudes        double precision[],
    speeds_mps       double precision[],
    heart_rates      integer[],
    cadences         integer[],
    powers_w         integer[],
    temperatures_c   double precision[]
);

-- -----------------------------------------------------------------------------
-- 2. Indexes
-- -----------------------------------------------------------------------------

create index if not exists idx_activities_user_started
    on public.activities (user_id, started_at desc);

create index if not exists idx_activities_user_type_started
    on public.activities (user_id, type, started_at desc);

create index if not exists idx_activities_user_external
    on public.activities (user_id, external_id)
    where external_id is not null;

-- -----------------------------------------------------------------------------
-- 3. Row Level Security
-- -----------------------------------------------------------------------------

alter table public.activities       enable row level security;
alter table public.activity_streams enable row level security;

drop policy if exists "activities_select_own" on public.activities;
drop policy if exists "activities_insert_own" on public.activities;
drop policy if exists "activities_update_own" on public.activities;
drop policy if exists "activities_delete_own" on public.activities;

create policy "activities_select_own"
    on public.activities for select
    using (user_id = (select auth.uid()));

create policy "activities_insert_own"
    on public.activities for insert
    with check (user_id = (select auth.uid()));

create policy "activities_update_own"
    on public.activities for update
    using (user_id = (select auth.uid()))
    with check (user_id = (select auth.uid()));

create policy "activities_delete_own"
    on public.activities for delete
    using (user_id = (select auth.uid()));

-- activity_streams: ownership flows through parent activity.
drop policy if exists "activity_streams_select_own" on public.activity_streams;
drop policy if exists "activity_streams_insert_own" on public.activity_streams;
drop policy if exists "activity_streams_update_own" on public.activity_streams;
drop policy if exists "activity_streams_delete_own" on public.activity_streams;

create policy "activity_streams_select_own"
    on public.activity_streams for select
    using (
        exists (
            select 1 from public.activities a
            where a.id = activity_streams.activity_id
              and a.user_id = (select auth.uid())
        )
    );

create policy "activity_streams_insert_own"
    on public.activity_streams for insert
    with check (
        exists (
            select 1 from public.activities a
            where a.id = activity_streams.activity_id
              and a.user_id = (select auth.uid())
        )
    );

create policy "activity_streams_update_own"
    on public.activity_streams for update
    using (
        exists (
            select 1 from public.activities a
            where a.id = activity_streams.activity_id
              and a.user_id = (select auth.uid())
        )
    )
    with check (
        exists (
            select 1 from public.activities a
            where a.id = activity_streams.activity_id
              and a.user_id = (select auth.uid())
        )
    );

create policy "activity_streams_delete_own"
    on public.activity_streams for delete
    using (
        exists (
            select 1 from public.activities a
            where a.id = activity_streams.activity_id
              and a.user_id = (select auth.uid())
        )
    );

-- -----------------------------------------------------------------------------
-- 4. updated_at trigger
-- -----------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

drop trigger if exists trg_activities_set_updated_at on public.activities;
create trigger trg_activities_set_updated_at
    before update on public.activities
    for each row execute function public.set_updated_at();
