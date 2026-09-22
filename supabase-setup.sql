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

-- Editable biography timeline. These rows define the nodes shown on the site.
create table if not exists public.life_stages (
  id uuid primary key default gen_random_uuid(),
  sort_order integer not null check (sort_order >= 0),
  period text not null check (char_length(period) between 1 and 30),
  name text not null check (char_length(name) between 1 and 20),
  chapter text not null check (char_length(chapter) between 1 and 60),
  title text not null check (char_length(title) between 1 and 80),
  lead text not null check (char_length(lead) between 1 and 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists life_stages_sort_order_idx
on public.life_stages(sort_order, created_at);

-- Seed the current five nodes only when no timeline has been created yet.
insert into public.life_stages (sort_order, period, name, chapter, title, lead)
select seed.sort_order, seed.period, seed.name, seed.chapter, seed.title, seed.lead
from (
  values
    (0, '0—12 岁', '童年', '第一章 · 最初的世界', '一切故事，都从这里开始', '那时候，世界很小，小到只装得下家、学校和放学路上的风。许多性格的底色，也在这些看似平常的日子里悄悄形成。'),
    (1, '13—17 岁', '少年', '第二章 · 开始认识自己', '在好奇与倔强之间长大', '青春把生活忽然推远，也把内心忽然放大。我开始拥有自己的判断，第一次认真思考想成为怎样的人。'),
    (2, '18—22 岁', '远行', '第三章 · 走向更大的世界', '离开熟悉的坐标之后', '第一次真正意义上的远行，让我看见不同的生活，也重新理解来处。自由和责任，大概就是从这时一起抵达的。'),
    (3, '23 岁至今', '生长', '第四章 · 成为自己的过程', '生活没有答案，只有行动', '进入真实世界以后，我一边解决问题，一边更新自己。那些走过的弯路、完成的作品和真心珍惜的人，共同组成此刻的我。'),
    (4, '未来', '待续', '下一章 · 尚未抵达', '把空白留给明天', '未来不是一个等着被揭晓的答案，而是今天的选择一点点写成的故事。愿我一直保留出发的勇气，也保留回望的温柔。')
) as seed(sort_order, period, name, chapter, title, lead)
where not exists (select 1 from public.life_stages);

alter table public.life_stages enable row level security;

drop policy if exists life_stages_read_signed_in on public.life_stages;
drop policy if exists life_stages_owner_insert on public.life_stages;
drop policy if exists life_stages_owner_update on public.life_stages;

create policy life_stages_read_signed_in
on public.life_stages for select
to authenticated
using (true);

create policy life_stages_owner_insert
on public.life_stages for insert
to authenticated
with check (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
);

create policy life_stages_owner_update
on public.life_stages for update
to authenticated
using (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
)
with check (
  lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
);

revoke all on table public.life_stages from anon;
grant select, insert, update on table public.life_stages to authenticated;

-- Shared biography memories. All signed-in users can read them,
-- but only the verified owner email can create, edit or delete them.
create table if not exists public.life_memories (
  id uuid primary key default gen_random_uuid(),
  stage smallint,
  stage_id uuid not null references public.life_stages(id),
  event_date text not null check (char_length(event_date) between 1 and 30),
  title text not null check (char_length(title) between 1 and 80),
  description text not null check (char_length(description) between 1 and 1000),
  tag text not null default '记忆' check (char_length(tag) between 1 and 20),
  media_path text,
  media_type text,
  media_mime text,
  media_name text,
  media_size bigint,
  author_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Safe to run for an existing life_memories table.
alter table public.life_memories add column if not exists media_path text;
alter table public.life_memories add column if not exists media_type text;
alter table public.life_memories add column if not exists media_mime text;
alter table public.life_memories add column if not exists media_name text;
alter table public.life_memories add column if not exists media_size bigint;
alter table public.life_memories add column if not exists stage_id uuid
  references public.life_stages(id);

-- Refresh the MIME constraint when new browser-playable formats are added.
alter table public.life_memories drop constraint if exists life_memories_media_mime_check;
alter table public.life_memories
  add constraint life_memories_media_mime_check
  check (
    media_mime is null or media_mime in (
      'image/jpeg', 'image/png', 'image/webp', 'image/gif',
      'video/mp4', 'video/webm', 'video/ogg',
        'video/quicktime', 'video/x-m4v', 'video/mpeg', 'video/x-matroska'
    )
  );

-- Link memories created by the previous fixed five-node version.
update public.life_memories as memory
set stage_id = timeline.id
from public.life_stages as timeline
where memory.stage_id is null
  and timeline.sort_order = memory.stage;

alter table public.life_memories drop constraint if exists life_memories_stage_check;
alter table public.life_memories alter column stage drop not null;
alter table public.life_memories alter column stage_id set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'life_memories_media_type_check'
      and conrelid = 'public.life_memories'::regclass
  ) then
    alter table public.life_memories
      add constraint life_memories_media_type_check
      check (media_type is null or media_type in ('image', 'video'));
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'life_memories_media_mime_check'
      and conrelid = 'public.life_memories'::regclass
  ) then
    alter table public.life_memories
      add constraint life_memories_media_mime_check
      check (
        media_mime is null or media_mime in (
          'image/jpeg', 'image/png', 'image/webp', 'image/gif',
          'video/mp4', 'video/webm', 'video/ogg',
          'video/quicktime', 'video/x-m4v', 'video/mpeg', 'video/x-matroska'
        )
      );
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'life_memories_media_size_check'
      and conrelid = 'public.life_memories'::regclass
  ) then
    alter table public.life_memories
      add constraint life_memories_media_size_check
      check (media_size is null or media_size between 1 and 52428800);
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'life_memories_media_name_check'
      and conrelid = 'public.life_memories'::regclass
  ) then
    alter table public.life_memories
      add constraint life_memories_media_name_check
      check (media_name is null or char_length(media_name) <= 255);
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'life_memories_media_path_check'
      and conrelid = 'public.life_memories'::regclass
  ) then
    alter table public.life_memories
      add constraint life_memories_media_path_check
      check (media_path is null or char_length(media_path) <= 500);
  end if;
end
$$;

create index if not exists life_memories_stage_created_idx
on public.life_memories(stage, created_at);

create index if not exists life_memories_stage_id_created_idx
on public.life_memories(stage_id, created_at);

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

-- Private media bucket for photos and videos. Running this is safe even if the
-- bucket was already created in the Dashboard with the same exact name.
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'Beautiful Memories',
  'Beautiful Memories',
  false,
  52428800,
  array[
    'image/jpeg', 'image/png', 'image/webp', 'image/gif',
    'video/mp4', 'video/webm', 'video/ogg',
    'video/quicktime', 'video/x-m4v', 'video/mpeg', 'video/x-matroska'
  ]::text[]
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists beautiful_memories_read_signed_in on storage.objects;
drop policy if exists beautiful_memories_owner_insert on storage.objects;
drop policy if exists beautiful_memories_owner_delete on storage.objects;

create policy beautiful_memories_read_signed_in
on storage.objects for select
to authenticated
using (bucket_id = 'Beautiful Memories');

create policy beautiful_memories_owner_insert
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'Beautiful Memories'
  and lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy beautiful_memories_owner_delete
on storage.objects for delete
to authenticated
using (
  bucket_id = 'Beautiful Memories'
  and lower(coalesce(auth.jwt() ->> 'email', '')) = '1223157269@qq.com'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

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

drop trigger if exists life_stages_set_updated_at on public.life_stages;
create trigger life_stages_set_updated_at
before update on public.life_stages
for each row execute function public.set_updated_at();
