-- Homepage "About me" section. Run once in Supabase Dashboard > SQL Editor.
-- Safe to rerun: existing title and body are preserved.

begin;

create table if not exists public.site_overview (
  id smallint primary key default 1 check (id = 1),
  title text not null check (char_length(btrim(title)) between 1 and 100),
  body text not null check (char_length(btrim(body)) between 1 and 10000),
  updated_at timestamptz not null default now()
);

alter table public.site_overview enable row level security;

drop policy if exists site_overview_read_signed_in on public.site_overview;
drop policy if exists site_overview_owner_insert on public.site_overview;
drop policy if exists site_overview_owner_update on public.site_overview;

create policy site_overview_read_signed_in
on public.site_overview for select
to authenticated
using (true);

create policy site_overview_owner_insert
on public.site_overview for insert
to authenticated
with check (
  id = 1
  and lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
);

create policy site_overview_owner_update
on public.site_overview for update
to authenticated
using (
  id = 1
  and lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
)
with check (
  id = 1
  and lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
);

revoke all on table public.site_overview from anon;
grant select, insert, update on table public.site_overview to authenticated;

commit;
