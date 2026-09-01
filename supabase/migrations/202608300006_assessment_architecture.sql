-- Phase 7: extensible assessment blueprints and quiz/test classification.
create type public.assessment_type as enum ('mock_test', 'practice_quiz');

create table public.exam_blueprints (
  id uuid primary key default gen_random_uuid(),
  university_id uuid references public.universities(id) on delete cascade,
  program_id uuid references public.programs(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 180),
  description text,
  version integer not null default 1 check (version > 0),
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (program_id, name, version)
);

create table public.exam_blueprint_sections (
  id uuid primary key default gen_random_uuid(),
  blueprint_id uuid not null references public.exam_blueprints(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete restrict,
  name text not null check (char_length(name) between 2 and 120),
  question_count integer not null check (question_count > 0),
  section_order integer not null check (section_order > 0),
  question_filters jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (blueprint_id, section_order)
);

alter table public.mock_tests
  add column assessment_type public.assessment_type not null default 'mock_test',
  add column blueprint_id uuid references public.exam_blueprints(id) on delete set null;

create trigger exam_blueprints_set_updated_at before update on public.exam_blueprints for each row execute function public.set_updated_at();
create trigger blueprint_sections_set_updated_at before update on public.exam_blueprint_sections for each row execute function public.set_updated_at();
create index exam_blueprints_catalog_idx on public.exam_blueprints (university_id, program_id, status, version desc);
create index blueprint_sections_lookup_idx on public.exam_blueprint_sections (blueprint_id, section_order);
create index mock_tests_type_status_idx on public.mock_tests (assessment_type, status, created_at desc);

alter table public.exam_blueprints enable row level security;
alter table public.exam_blueprint_sections enable row level security;
create policy "Published blueprints are publicly readable" on public.exam_blueprints for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Published blueprint sections are publicly readable" on public.exam_blueprint_sections for select to anon, authenticated using (exists (select 1 from public.exam_blueprints b where b.id = blueprint_id and b.status = 'published') or (select public.is_admin()));
create policy "Admins manage blueprints" on public.exam_blueprints for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "Admins manage blueprint sections" on public.exam_blueprint_sections for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
