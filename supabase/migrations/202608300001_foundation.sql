-- NEXTGEN TESTING SERVICE: foundational schema
create type public.user_role as enum ('student', 'instructor', 'admin');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text check (char_length(full_name) <= 120),
  role public.user_role not null default 'student',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.programs (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 2 and 120),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  description text,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin new.updated_at = now(); return new; end; $$;

create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, left(new.raw_user_meta_data ->> 'full_name', 120));
  return new;
end; $$;

create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

alter table public.profiles enable row level security;
alter table public.programs enable row level security;

create policy "Users can view their own profile" on public.profiles
for select to authenticated using ((select auth.uid()) = id);
create policy "Users can update their own profile" on public.profiles
for update to authenticated using ((select auth.uid()) = id)
with check ((select auth.uid()) = id and role = (select role from public.profiles where id = auth.uid()));
create policy "Admins can view all profiles" on public.profiles
for select to authenticated using ((select public.is_admin()));
create policy "Published programs are publicly readable" on public.programs
for select to anon, authenticated using (is_published or (select public.is_admin()));
create policy "Admins manage programs" on public.programs
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create index programs_published_idx on public.programs (is_published, created_at desc);

-- Content belongs in PostgreSQL, not the frontend. Add program records from the admin flow or SQL editor.
