-- Run in Supabase SQL Editor. Safe to rerun.
-- Each click is an individual row tied to the signed-in account.
begin;

create table if not exists public.site_like_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Carry over one existing like per account from the earlier one-like-per-user table.
-- Using user_id as the imported event ID makes rerunning this migration idempotent.
do $$
begin
  if to_regclass('public.site_likes') is not null then
    insert into public.site_like_events (id, user_id, created_at)
    select user_id, user_id, created_at from public.site_likes
    on conflict (id) do nothing;
  end if;
end;
$$;

create index if not exists site_like_events_user_time_idx
  on public.site_like_events (user_id, created_at desc);

alter table public.site_like_events enable row level security;

drop policy if exists "site_like_events_insert_own" on public.site_like_events;
create policy "site_like_events_insert_own"
  on public.site_like_events for insert to authenticated
  with check (user_id = (select auth.uid()));

-- No client SELECT/UPDATE/DELETE policy: visitors cannot inspect another account's clicks.
revoke all on public.site_like_events from public, anon, authenticated;
grant insert on public.site_like_events to authenticated;

create or replace function public.get_site_like_click_count()
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::bigint from public.site_like_events;
$$;

revoke all on function public.get_site_like_click_count() from public, anon;
grant execute on function public.get_site_like_click_count() to authenticated;

commit;

-- Optional, for the site owner in SQL Editor (not exposed to the website):
-- select u.email, count(*) as clicks
-- from public.site_like_events e join auth.users u on u.id = e.user_id
-- group by u.email order by clicks desc;
