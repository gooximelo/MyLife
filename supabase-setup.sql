-- Gooxi21 authentication, profile and biography permissions.
-- Run this entire file once in Supabase Dashboard -> SQL Editor.

-- Every account owns exactly one profile card.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text check (char_length(nickname) <= 40)
);

alter table public.profiles enable row level security;

drop policy if exists profiles_select_own on public.profiles;
drop policy if exists profiles_insert_own on public.profiles;
drop policy if exists profiles_update_own on public.profiles;

create policy profiles_select_own
on public.profiles for select
to authenticated
using (auth.uid() = id);

create policy profiles_insert_own
on public.profiles for insert
to authenticated
with check (auth.uid() = id);

create policy profiles_update_own
on public.profiles for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

revoke all on table public.profiles from anon;
grant select, insert, update on table public.profiles to authenticated;

-- Shared biography memories. All signed-in users can read them,
-- but only the verified owner email can create, edit or delete them.
create table if not exists public.life_memories (
  id uuid primary key default gen_random_uuid(),
  stage smallint not null check (stage between 0 and 4),
  event_date text not null check (char_length(event_date) between 1 and 30),
  title text not null check (char_length(title) between 1 and 80),
  description text not null check (char_length(description) between 1 and 1000),
  tag text not null default '记忆' check (char_length(tag) between 1 and 20),
  author_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists life_memories_stage_created_idx
on public.life_memories(stage, created_at);

alter table public.life_memories enable row level security;

drop policy if exists life_memories_read_signed_in on public.life_memories;
drop policy if exists life_memories_owner_insert on public.life_memories;
drop policy if exists life_memories_owner_update on public.life_memories;
drop policy if exists life_memories_owner_delete on public.life_memories;

create policy life_memories_read_signed_in
on public.life_memories for select
to authenticated
using (true);

create policy life_memories_owner_insert
on public.life_memories for insert
to authenticated
with check (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and author_id = auth.uid()
);

create policy life_memories_owner_update
on public.life_memories for update
to authenticated
using (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and author_id = auth.uid()
)
with check (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and author_id = auth.uid()
);

create policy life_memories_owner_delete
on public.life_memories for delete
to authenticated
using (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and author_id = auth.uid()
);

revoke all on table public.life_memories from anon;
grant select, insert, update, delete on table public.life_memories to authenticated;

-- Keep updated_at accurate when memories are edited later.
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

drop trigger if exists life_memories_set_updated_at on public.life_memories;
create trigger life_memories_set_updated_at
before update on public.life_memories
for each row execute function public.set_updated_at();
