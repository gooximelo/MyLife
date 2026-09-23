-- Homepage recent-updates announcement board.
-- Run this file once in Supabase Dashboard -> SQL Editor.
-- It is safe to run again.

begin;

create table if not exists public.site_announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 60),
  content text not null check (char_length(content) between 1 and 600),
  published_on date not null default current_date,
  author_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists site_announcements_recent_idx
on public.site_announcements(published_on desc, created_at desc);

alter table public.site_announcements enable row level security;

drop policy if exists site_announcements_read_signed_in
on public.site_announcements;
drop policy if exists site_announcements_owner_insert
on public.site_announcements;
drop policy if exists site_announcements_owner_update
on public.site_announcements;
drop policy if exists site_announcements_owner_delete
on public.site_announcements;

create policy site_announcements_read_signed_in
on public.site_announcements for select
to authenticated
using (true);

create policy site_announcements_owner_insert
on public.site_announcements for insert
to authenticated
with check (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and author_id = auth.uid()
);

create policy site_announcements_owner_update
on public.site_announcements for update
to authenticated
using (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and author_id = auth.uid()
)
with check (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and author_id = auth.uid()
);

create policy site_announcements_owner_delete
on public.site_announcements for delete
to authenticated
using (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and author_id = auth.uid()
);

revoke all on table public.site_announcements from anon;
grant select, insert, update, delete
on table public.site_announcements to authenticated;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists site_announcements_set_updated_at
on public.site_announcements;
create trigger site_announcements_set_updated_at
before update on public.site_announcements
for each row execute function public.set_updated_at();

commit;
