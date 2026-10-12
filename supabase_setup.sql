-- 在 Supabase Dashboard > SQL Editor 執行
create extension if not exists pgcrypto;

create table if not exists public.baby_events (
 id text primary key,
 title text not null default '猜猜寶寶性別',
 answer text check (answer in ('boy','girl') or answer is null),
 revealed boolean not null default false,
 host_id uuid references auth.users(id),
 created_at timestamptz not null default now()
);
create table if not exists public.baby_votes (
 id uuid primary key default gen_random_uuid(),
 event_id text not null references public.baby_events(id) on delete cascade,
 nickname text not null check (char_length(nickname) between 1 and 24),
 choice text not null check (choice in ('boy','girl')),
 created_at timestamptz not null default now()
);
create index if not exists baby_votes_event_id_idx on public.baby_votes(event_id);
alter table public.baby_events enable row level security;
alter table public.baby_votes enable row level security;

drop policy if exists "public can read event" on public.baby_events;
create policy "public can read event" on public.baby_events for select to anon, authenticated using (true);
drop policy if exists "public can read votes" on public.baby_votes;
create policy "public can read votes" on public.baby_votes for select to anon, authenticated using (true);
drop policy if exists "public can submit votes" on public.baby_votes;
create policy "public can submit votes" on public.baby_votes for insert to anon, authenticated
with check (char_length(nickname) between 1 and 24 and choice in ('boy','girl') and exists(select 1 from public.baby_events e where e.id=event_id));
drop policy if exists "host can update own event" on public.baby_events;
create policy "host can update own event" on public.baby_events for update to authenticated using (host_id=auth.uid()) with check (host_id=auth.uid());

insert into public.baby_events(id,title,answer,revealed) values('baby-shower-2026','猜猜寶寶性別',null,false) on conflict(id) do nothing;

do $$ begin alter publication supabase_realtime add table public.baby_votes; exception when duplicate_object then null; when undefined_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.baby_events; exception when duplicate_object then null; when undefined_object then null; end $$;

-- 先在 Authentication > Users 建立主持人帳號，複製該使用者 UUID，
-- 然後將下面 UUID 替換後單獨執行：
-- update public.baby_events set host_id = '主持人使用者UUID' where id = 'baby-shower-2026';

-- 注意：此入門版用瀏覽器 localStorage 降低重複投票，並非嚴格身份驗證；
-- 50 票上限也有前端限制，無法抵禦刻意繞過限制的人。公開讀取可供統計使用，
-- 但熟悉 API 的人可能讀取投票暱稱與選項。正式大型活動可再升級為伺服器端驗證。
