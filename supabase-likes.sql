-- Run this once in the Supabase SQL Editor to enable the site's like button.
-- One account has at most one like; visitors can only read or change their own row.
begin;

create table if not exists public.site_likes (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.site_likes enable row level security;

drop policy if exists "site_likes_read_own" on public.site_likes;
create policy "site_likes_read_own"
  on public.site_likes for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "site_likes_insert_own" on public.site_likes;
create policy "site_likes_insert_own"
  on public.site_likes for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "site_likes_delete_own" on public.site_likes;
create policy "site_likes_delete_own"
  on public.site_likes for delete to authenticated
  using (user_id = (select auth.uid()));

revoke all on public.site_likes from anon;
grant select, insert, delete on public.site_likes to authenticated;

-- Return only the total, never another visitor's user_id.
create or replace function public.get_site_like_count()
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::bigint from public.site_likes;
$$;

revoke all on function public.get_site_like_count() from public, anon;
grant execute on function public.get_site_like_count() to authenticated;

commit;
