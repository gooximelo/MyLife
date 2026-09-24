-- Footer contact details. Run once in Supabase Dashboard > SQL Editor.
-- Safe to rerun: previously saved address and email are preserved.

begin;

create table if not exists public.site_contact (
  id smallint primary key default 1 check (id = 1),
  address text not null default '' check (char_length(address) <= 240),
  email text not null default '' check (char_length(email) <= 254),
  updated_at timestamptz not null default now()
);

alter table public.site_contact enable row level security;

drop policy if exists site_contact_read_signed_in on public.site_contact;
drop policy if exists site_contact_owner_insert on public.site_contact;
drop policy if exists site_contact_owner_update on public.site_contact;

create policy site_contact_read_signed_in
on public.site_contact for select
to authenticated
using (true);

create policy site_contact_owner_insert
on public.site_contact for insert
to authenticated
with check (
  id = 1
  and lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
);

create policy site_contact_owner_update
on public.site_contact for update
to authenticated
using (
  id = 1
  and lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
)
with check (
  id = 1
  and lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
);

revoke all on table public.site_contact from anon;
grant select, insert, update on table public.site_contact to authenticated;

commit;
