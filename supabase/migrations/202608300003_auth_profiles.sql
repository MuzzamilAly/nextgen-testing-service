-- Phase 2: authentication profile expansion and role protection.
alter table public.profiles
  add column if not exists email text,
  add column if not exists phone text,
  add column if not exists profile_photo text,
  add column if not exists target_university text,
  add column if not exists target_program text;

update public.profiles p set email = u.email
from auth.users u where p.id = u.id and p.email is null;
alter table public.profiles alter column email set not null;

alter table public.profiles
  add constraint profiles_phone_length check (phone is null or char_length(phone) <= 30),
  add constraint profiles_photo_length check (profile_photo is null or char_length(profile_photo) <= 2048),
  add constraint profiles_target_university_length check (target_university is null or char_length(target_university) <= 160),
  add constraint profiles_target_program_length check (target_program is null or char_length(target_program) <= 120);

-- Replace the foundation signup trigger so email is mirrored into the public profile.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name, email, role)
  values (new.id, left(new.raw_user_meta_data ->> 'full_name', 120), new.email, 'student');
  return new;
end; $$;

-- A signed-in user may edit profile data but may never change their own role.
create or replace function public.prevent_profile_privilege_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() = old.id and not public.is_admin() then
    new.role := old.role;
    new.email := old.email;
  end if;
  return new;
end; $$;

create trigger protect_profile_privileges before update on public.profiles
for each row execute function public.prevent_profile_privilege_change();

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile" on public.profiles
for update to authenticated using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

-- Only student and admin are application roles. The legacy enum value is retained
-- for safe PostgreSQL migration compatibility, but cannot be assigned by clients.
update public.profiles set role = 'student' where role = 'instructor';
