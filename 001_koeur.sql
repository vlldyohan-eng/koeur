create extension if not exists pgcrypto;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null,
 birth_date date,
 city text,
 bio text default '',
 verified boolean not null default false,
 premium_until timestamptz,
 xp integer not null default 0 check(xp between 0 and 100),
 element text not null default 'feu' check(element in('feu','eau','air','terre','ether')),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.profile_answers (
 user_id uuid primary key references public.profiles(id) on delete cascade,
 values_score integer not null default 50 check(values_score between 0 and 100),
 communication_score integer not null default 50 check(communication_score between 0 and 100),
 life_project_score integer not null default 50 check(life_project_score between 0 and 100),
 lifestyle_score integer not null default 50 check(lifestyle_score between 0 and 100),
 interests_score integer not null default 50 check(interests_score between 0 and 100),
 updated_at timestamptz not null default now()
);
create table if not exists public.photos (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id) on delete cascade,
 storage_path text not null, position integer not null default 0,
 created_at timestamptz not null default now()
);
create table if not exists public.likes (
 from_user uuid not null references public.profiles(id) on delete cascade,
 to_user uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now(),
 primary key(from_user,to_user), check(from_user<>to_user)
);
create table if not exists public.matches (
 id uuid primary key default gen_random_uuid(),
 user_a uuid not null references public.profiles(id) on delete cascade,
 user_b uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now(),
 unique(user_a,user_b), check(user_a<user_b)
);
create table if not exists public.messages (
 id uuid primary key default gen_random_uuid(),
 match_id uuid not null references public.matches(id) on delete cascade,
 sender_id uuid not null references public.profiles(id) on delete cascade,
 body text not null check(char_length(body) between 1 and 2000),
 created_at timestamptz not null default now()
);
create table if not exists public.compatibility_scores (
 id uuid primary key default gen_random_uuid(),
 user_a uuid not null references public.profiles(id) on delete cascade,
 user_b uuid not null references public.profiles(id) on delete cascade,
 score integer not null check(score between 0 and 100),
 values_score integer not null, communication_score integer not null,
 life_project_score integer not null, lifestyle_score integer not null,
 interests_score integer not null, explanation text not null,
 created_at timestamptz not null default now(), unique(user_a,user_b)
);
create table if not exists public.missions (
 id uuid primary key default gen_random_uuid(), code text unique not null,
 title text not null, xp integer not null default 25, active boolean not null default true
);
create table if not exists public.user_missions (
 user_id uuid not null references public.profiles(id) on delete cascade,
 mission_id uuid not null references public.missions(id) on delete cascade,
 completed_at timestamptz not null default now(), primary key(user_id,mission_id)
);
create table if not exists public.verifications (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 provider text not null, status text not null default 'pending' check(status in('pending','approved','rejected')),
 provider_reference text, created_at timestamptz not null default now()
);
create table if not exists public.reports (
 id uuid primary key default gen_random_uuid(), reporter_id uuid not null references public.profiles(id) on delete cascade,
 reported_id uuid not null references public.profiles(id) on delete cascade,
 reason text not null, details text default '', status text not null default 'open' check(status in('open','reviewing','closed')),
 created_at timestamptz not null default now()
);
create table if not exists public.blocks (
 blocker_id uuid not null references public.profiles(id) on delete cascade,
 blocked_id uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now(), primary key(blocker_id,blocked_id), check(blocker_id<>blocked_id)
);

alter table public.profiles enable row level security;
alter table public.profile_answers enable row level security;
alter table public.photos enable row level security;
alter table public.likes enable row level security;
alter table public.matches enable row level security;
alter table public.messages enable row level security;
alter table public.compatibility_scores enable row level security;
alter table public.missions enable row level security;
alter table public.user_missions enable row level security;
alter table public.verifications enable row level security;
alter table public.reports enable row level security;
alter table public.blocks enable row level security;

create policy "profiles read" on public.profiles for select to authenticated using(true);
create policy "own profile insert" on public.profiles for insert to authenticated with check(id=auth.uid());
create policy "own profile update" on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
create policy "own answers" on public.profile_answers for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "photos read" on public.photos for select to authenticated using(true);
create policy "own photos insert" on public.photos for insert to authenticated with check(user_id=auth.uid());
create policy "own photos delete" on public.photos for delete to authenticated using(user_id=auth.uid());
create policy "likes insert" on public.likes for insert to authenticated with check(from_user=auth.uid());
create policy "likes read" on public.likes for select to authenticated using(from_user=auth.uid() or to_user=auth.uid());
create policy "matches read" on public.matches for select to authenticated using(user_a=auth.uid() or user_b=auth.uid());
create policy "messages read" on public.messages for select to authenticated using(exists(select 1 from public.matches m where m.id=match_id and (m.user_a=auth.uid() or m.user_b=auth.uid())));
create policy "messages send" on public.messages for insert to authenticated with check(sender_id=auth.uid() and exists(select 1 from public.matches m where m.id=match_id and (m.user_a=auth.uid() or m.user_b=auth.uid())));
create policy "compatibility read" on public.compatibility_scores for select to authenticated using(user_a=auth.uid() or user_b=auth.uid());
create policy "missions read" on public.missions for select to authenticated using(active=true);
create policy "user missions own" on public.user_missions for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "verification own read" on public.verifications for select to authenticated using(user_id=auth.uid());
create policy "verification own insert" on public.verifications for insert to authenticated with check(user_id=auth.uid());
create policy "reports insert" on public.reports for insert to authenticated with check(reporter_id=auth.uid());
create policy "blocks own" on public.blocks for all to authenticated using(blocker_id=auth.uid()) with check(blocker_id=auth.uid());

insert into public.missions(code,title,xp) values
('complete_profile','Compléter son profil',25),
('send_messages','Envoyer 3 messages respectueux',25),
('get_koeurs','Obtenir 3 Koeurs',25),
('discover_element','Découvrir un nouvel élément',25)
on conflict(code) do nothing;


-- Création automatique d'un match lorsqu'un like réciproque existe.
create or replace function public.create_match_on_reciprocal_like()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if exists (
    select 1 from public.likes
    where from_user = new.to_user and to_user = new.from_user
  ) then
    insert into public.matches(user_a,user_b)
    values (
      least(new.from_user,new.to_user),
      greatest(new.from_user,new.to_user)
    )
    on conflict (user_a,user_b) do nothing;
  end if;
  return new;
end;
$$;

drop trigger if exists likes_match_trigger on public.likes;
create trigger likes_match_trigger
after insert on public.likes
for each row execute function public.create_match_on_reciprocal_like();

-- Permettre aux membres d'un match d'envoyer des messages.
drop policy if exists "messages members send" on public.messages;
create policy "messages members send" on public.messages
for insert to authenticated
with check (
  sender_id = auth.uid()
  and exists (
    select 1 from public.matches m
    where m.id = match_id
      and (m.user_a = auth.uid() or m.user_b = auth.uid())
  )
);

-- Les membres peuvent lire les profils, mais les données sensibles
-- ne doivent pas être stockées dans profiles.
