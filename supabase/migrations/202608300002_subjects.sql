create table public.subjects (
  id uuid primary key default gen_random_uuid(),
  title text not null unique check (char_length(title) between 2 and 80),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  description text,
  display_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.subjects enable row level security;
create policy "Published subjects are publicly readable" on public.subjects
for select to anon, authenticated using (is_published or (select public.is_admin()));
create policy "Admins manage subjects" on public.subjects
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create index subjects_catalog_idx on public.subjects (is_published, display_order, title);

insert into public.subjects (title, slug, description, display_order, is_published) values
  ('Biology', 'biology', 'Cells, genetics, physiology and life systems.', 10, true),
  ('Chemistry', 'chemistry', 'Core concepts, reactions and organic chemistry.', 20, true),
  ('Physics', 'physics', 'Mechanics, waves, electricity and applied physics.', 30, true),
  ('English', 'english', 'Grammar, vocabulary and comprehension skills.', 40, true);
