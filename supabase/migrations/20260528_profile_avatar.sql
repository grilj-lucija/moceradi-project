-- =============================================================================
-- Profile avatar + username availability
-- =============================================================================
-- Adds avatar_url to public.profiles, a public 'avatars' storage bucket with
-- per-user write access, and an RPC for checking whether a username is free
-- without exposing the underlying rows.
-- Idempotent: safe to re-run.
-- =============================================================================

set search_path = public;

-- -----------------------------------------------------------------------------
-- 1. Column
-- -----------------------------------------------------------------------------

alter table public.profiles
    add column if not exists avatar_url text;

-- -----------------------------------------------------------------------------
-- 2. Storage bucket
-- -----------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = excluded.public;

-- -----------------------------------------------------------------------------
-- 3. Storage policies
-- -----------------------------------------------------------------------------

drop policy if exists "avatars_public_read"   on storage.objects;
drop policy if exists "avatars_insert_own"    on storage.objects;
drop policy if exists "avatars_update_own"    on storage.objects;
drop policy if exists "avatars_delete_own"    on storage.objects;

create policy "avatars_public_read"
    on storage.objects for select
    using (bucket_id = 'avatars');

create policy "avatars_insert_own"
    on storage.objects for insert
    with check (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = (select auth.uid())::text
    );

create policy "avatars_update_own"
    on storage.objects for update
    using (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = (select auth.uid())::text
    )
    with check (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = (select auth.uid())::text
    );

create policy "avatars_delete_own"
    on storage.objects for delete
    using (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = (select auth.uid())::text
    );

-- -----------------------------------------------------------------------------
-- 4. Username availability RPC
-- -----------------------------------------------------------------------------

create or replace function public.is_username_available(p_username text)
returns boolean
language sql
security definer
set search_path = public
as $$
    select not exists (
        select 1
        from public.profiles
        where lower(username) = lower(p_username)
          and id <> (select auth.uid())
    );
$$;

revoke all on function public.is_username_available(text) from public;
grant execute on function public.is_username_available(text) to authenticated;
