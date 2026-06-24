-- Marketing Hub + Supabase
-- Wklej cały plik w Supabase: SQL Editor -> New query -> Run.

create extension if not exists pgcrypto;

create table if not exists public.marketing_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  role text default 'marketing',
  created_at timestamptz default now()
);

create table if not exists public.marketing_items (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  data jsonb not null default '{}'::jsonb,
  owner_id uuid references auth.users(id) on delete set null default auth.uid(),
  visibility text not null default 'team' check (visibility in ('team','private')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create or replace function public.set_marketing_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_marketing_items_updated on public.marketing_items;
create trigger trg_marketing_items_updated
before update on public.marketing_items
for each row execute function public.set_marketing_updated_at();

create or replace function public.create_marketing_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.marketing_profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    case when new.email = 'gosia@felg.app' then 'owner' else 'marketing' end
  )
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_marketing_profile on auth.users;
create trigger on_auth_user_created_marketing_profile
after insert on auth.users
for each row execute function public.create_marketing_profile();

alter table public.marketing_profiles enable row level security;
alter table public.marketing_items enable row level security;

-- Profile: wszyscy zalogowani z firmowej domeny widzą zespół.
drop policy if exists "profiles_select_team" on public.marketing_profiles;
create policy "profiles_select_team" on public.marketing_profiles
for select to authenticated
using ((auth.jwt()->>'email') like '%@felg.app');

drop policy if exists "profiles_update_own" on public.marketing_profiles;
create policy "profiles_update_own" on public.marketing_profiles
for update to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- Items: wspólne widzi cały marketing, prywatne tylko właściciel.
drop policy if exists "items_select_team_or_private_owner" on public.marketing_items;
create policy "items_select_team_or_private_owner" on public.marketing_items
for select to authenticated
using (
  (auth.jwt()->>'email') like '%@felg.app'
  and (visibility = 'team' or owner_id = auth.uid())
);

drop policy if exists "items_insert_felg" on public.marketing_items;
create policy "items_insert_felg" on public.marketing_items
for insert to authenticated
with check (
  (auth.jwt()->>'email') like '%@felg.app'
  and owner_id = auth.uid()
);

drop policy if exists "items_update_team_or_own_private" on public.marketing_items;
create policy "items_update_team_or_own_private" on public.marketing_items
for update to authenticated
using (
  (auth.jwt()->>'email') like '%@felg.app'
  and (visibility = 'team' or owner_id = auth.uid())
)
with check (
  (auth.jwt()->>'email') like '%@felg.app'
  and (visibility = 'team' or owner_id = auth.uid())
);

drop policy if exists "items_delete_team_or_own_private" on public.marketing_items;
create policy "items_delete_team_or_own_private" on public.marketing_items
for delete to authenticated
using (
  (auth.jwt()->>'email') like '%@felg.app'
  and (visibility = 'team' or owner_id = auth.uid())
);

-- Bucket na pliki. Jeżeli bucket już istnieje, nic się nie stanie.
insert into storage.buckets (id, name, public)
values ('marketing-files', 'marketing-files', false)
on conflict (id) do nothing;

-- Storage: pliki dostępne dla zalogowanych osób z domeny @felg.app.
drop policy if exists "marketing_files_read" on storage.objects;
create policy "marketing_files_read" on storage.objects
for select to authenticated
using (bucket_id = 'marketing-files' and (auth.jwt()->>'email') like '%@felg.app');

drop policy if exists "marketing_files_upload" on storage.objects;
create policy "marketing_files_upload" on storage.objects
for insert to authenticated
with check (bucket_id = 'marketing-files' and (auth.jwt()->>'email') like '%@felg.app');

drop policy if exists "marketing_files_update" on storage.objects;
create policy "marketing_files_update" on storage.objects
for update to authenticated
using (bucket_id = 'marketing-files' and (auth.jwt()->>'email') like '%@felg.app')
with check (bucket_id = 'marketing-files' and (auth.jwt()->>'email') like '%@felg.app');

drop policy if exists "marketing_files_delete" on storage.objects;
create policy "marketing_files_delete" on storage.objects
for delete to authenticated
using (bucket_id = 'marketing-files' and (auth.jwt()->>'email') like '%@felg.app');
