-- NEXTGEN TESTING SERVICE — scalable examination data model

create type public.content_status as enum ('draft', 'published', 'archived');
create type public.question_difficulty as enum ('easy', 'medium', 'hard');
create type public.answer_option as enum ('a', 'b', 'c', 'd');
create type public.exam_attempt_status as enum ('in_progress', 'submitted', 'abandoned');

-- Academic catalog ----------------------------------------------------------
create table public.universities (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 180),
  short_name text check (short_name is null or char_length(short_name) <= 40),
  description text,
  location text check (location is null or char_length(location) <= 180),
  website_url text check (website_url is null or website_url ~ '^https?://'),
  logo_url text check (logo_url is null or logo_url ~ '^https?://'),
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- These Phase 1 policies reference legacy is_published columns and must be
-- removed before those columns can be replaced by the status enum.
drop policy if exists "Published programs are publicly readable" on public.programs;
drop policy if exists "Published subjects are publicly readable" on public.subjects;

-- Evolve foundation programs while preserving its IDs and existing rows.
alter table public.programs rename column title to name;
alter table public.programs
  add column university_id uuid references public.universities(id) on delete cascade,
  add column status public.content_status not null default 'draft',
  add column updated_at timestamptz not null default now();
update public.programs set status = case when is_published then 'published'::public.content_status else 'draft'::public.content_status end;
alter table public.programs alter column university_id set not null;
alter table public.programs drop column is_published;

-- Evolve foundation subjects while retaining useful slug/display ordering.
alter table public.subjects rename column title to name;
alter table public.subjects
  add column icon text check (icon is null or char_length(icon) <= 80),
  add column status public.content_status not null default 'draft',
  add column updated_at timestamptz not null default now();
update public.subjects set status = case when is_published then 'published'::public.content_status else 'draft'::public.content_status end;
alter table public.subjects drop column is_published;

create table public.chapters (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 180),
  description text,
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (subject_id, name)
);

create table public.topics (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.chapters(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 180),
  description text,
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (chapter_id, name)
);

create table public.study_materials (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  chapter_id uuid references public.chapters(id) on delete set null,
  topic_id uuid references public.topics(id) on delete set null,
  title text not null check (char_length(title) between 2 and 240),
  content text not null,
  description text,
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete restrict,
  chapter_id uuid references public.chapters(id) on delete set null,
  topic_id uuid references public.topics(id) on delete set null,
  question_text text not null check (char_length(question_text) >= 3),
  option_a text not null,
  option_b text not null,
  option_c text not null,
  option_d text not null,
  correct_answer public.answer_option not null,
  explanation text,
  difficulty public.question_difficulty not null default 'medium',
  source text check (source is null or char_length(source) <= 240),
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.mock_tests (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 180),
  description text,
  question_count integer not null check (question_count > 0),
  duration_minutes integer not null check (duration_minutes > 0),
  passing_percentage numeric(5,2) not null default 50 check (passing_percentage between 0 and 100),
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.mock_test_questions (
  id uuid primary key default gen_random_uuid(),
  mock_test_id uuid not null references public.mock_tests(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete restrict,
  question_order integer not null check (question_order > 0),
  created_at timestamptz not null default now(),
  unique (mock_test_id, question_id),
  unique (mock_test_id, question_order)
);

-- Student activity ----------------------------------------------------------
create table public.exam_attempts (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  mock_test_id uuid not null references public.mock_tests(id) on delete restrict,
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  status public.exam_attempt_status not null default 'in_progress',
  total_questions integer not null default 0 check (total_questions >= 0),
  correct_answers integer not null default 0 check (correct_answers >= 0),
  incorrect_answers integer not null default 0 check (incorrect_answers >= 0),
  unanswered integer not null default 0 check (unanswered >= 0),
  score numeric(10,2) not null default 0 check (score >= 0),
  percentage numeric(5,2) not null default 0 check (percentage between 0 and 100),
  time_used_seconds integer not null default 0 check (time_used_seconds >= 0),
  created_at timestamptz not null default now(),
  check (submitted_at is null or submitted_at >= started_at),
  check (correct_answers + incorrect_answers + unanswered <= total_questions)
);

create table public.attempt_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.exam_attempts(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete restrict,
  selected_answer public.answer_option,
  is_correct boolean,
  answered_at timestamptz not null default now(),
  unique (attempt_id, question_id)
);

create table public.student_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  topic_id uuid references public.topics(id) on delete cascade,
  questions_attempted integer not null default 0 check (questions_attempted >= 0),
  questions_correct integer not null default 0 check (questions_correct >= 0 and questions_correct <= questions_attempted),
  average_score numeric(5,2) not null default 0 check (average_score between 0 and 100),
  updated_at timestamptz not null default now()
);
create unique index student_progress_scope_unique on public.student_progress
  (student_id, subject_id, coalesce(topic_id, '00000000-0000-0000-0000-000000000000'::uuid));

-- Profile academic targets are relational, not free-form strings.
alter table public.profiles drop column if exists target_university;
alter table public.profiles drop column if exists target_program;
alter table public.profiles
  add column target_university_id uuid references public.universities(id) on delete set null,
  add column target_program_id uuid references public.programs(id) on delete set null;

-- Automatic timestamps ------------------------------------------------------
create trigger universities_set_updated_at before update on public.universities for each row execute function public.set_updated_at();
create trigger programs_set_updated_at before update on public.programs for each row execute function public.set_updated_at();
create trigger subjects_set_updated_at before update on public.subjects for each row execute function public.set_updated_at();
create trigger chapters_set_updated_at before update on public.chapters for each row execute function public.set_updated_at();
create trigger topics_set_updated_at before update on public.topics for each row execute function public.set_updated_at();
create trigger study_materials_set_updated_at before update on public.study_materials for each row execute function public.set_updated_at();
create trigger questions_set_updated_at before update on public.questions for each row execute function public.set_updated_at();
create trigger mock_tests_set_updated_at before update on public.mock_tests for each row execute function public.set_updated_at();

-- Query indexes -------------------------------------------------------------
create index programs_university_status_idx on public.programs (university_id, status);
create index chapters_subject_status_idx on public.chapters (subject_id, status);
create index topics_chapter_status_idx on public.topics (chapter_id, status);
create index materials_catalog_idx on public.study_materials (subject_id, chapter_id, topic_id, status);
create index questions_bank_idx on public.questions (subject_id, chapter_id, topic_id, difficulty, status);
create index mock_test_questions_test_idx on public.mock_test_questions (mock_test_id, question_order);
create index attempts_student_idx on public.exam_attempts (student_id, created_at desc);
create index attempts_test_idx on public.exam_attempts (mock_test_id, status);
create index answers_attempt_idx on public.attempt_answers (attempt_id);
create index progress_student_idx on public.student_progress (student_id, subject_id);

-- Row Level Security --------------------------------------------------------
alter table public.universities enable row level security;
alter table public.chapters enable row level security;
alter table public.topics enable row level security;
alter table public.study_materials enable row level security;
alter table public.questions enable row level security;
alter table public.mock_tests enable row level security;
alter table public.mock_test_questions enable row level security;
alter table public.exam_attempts enable row level security;
alter table public.attempt_answers enable row level security;
alter table public.student_progress enable row level security;

-- Replace earlier catalog policies after schema evolution.
drop policy if exists "Published programs are publicly readable" on public.programs;
drop policy if exists "Published subjects are publicly readable" on public.subjects;
create policy "Published programs are publicly readable" on public.programs for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Published subjects are publicly readable" on public.subjects for select to anon, authenticated using (status = 'published' or (select public.is_admin()));

create policy "Published universities are publicly readable" on public.universities for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Published chapters are publicly readable" on public.chapters for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Published topics are publicly readable" on public.topics for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Published materials are publicly readable" on public.study_materials for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Published tests are publicly readable" on public.mock_tests for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Published test questions are readable" on public.mock_test_questions for select to authenticated using (exists (select 1 from public.mock_tests t where t.id = mock_test_id and t.status = 'published') or (select public.is_admin()));

-- Correct answers are intentionally not directly readable by students.
create policy "Admins manage questions" on public.questions for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Students view own attempts" on public.exam_attempts for select to authenticated using (student_id = (select auth.uid()) or (select public.is_admin()));
create policy "Students create own attempts" on public.exam_attempts for insert to authenticated with check (student_id = (select auth.uid()));
create policy "Students update active own attempts" on public.exam_attempts for update to authenticated using (student_id = (select auth.uid()) and status = 'in_progress') with check (student_id = (select auth.uid()));
create policy "Students view own answers" on public.attempt_answers for select to authenticated using (exists (select 1 from public.exam_attempts a where a.id = attempt_id and (a.student_id = (select auth.uid()) or (select public.is_admin()))));
create policy "Students answer own active attempts" on public.attempt_answers for insert to authenticated with check (exists (select 1 from public.exam_attempts a where a.id = attempt_id and a.student_id = (select auth.uid()) and a.status = 'in_progress'));
create policy "Students update own active answers" on public.attempt_answers for update to authenticated using (exists (select 1 from public.exam_attempts a where a.id = attempt_id and a.student_id = (select auth.uid()) and a.status = 'in_progress'));
create policy "Students view own progress" on public.student_progress for select to authenticated using (student_id = (select auth.uid()) or (select public.is_admin()));

-- Admin authoring policies.
create policy "Admins manage universities" on public.universities for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "Admins manage chapters" on public.chapters for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "Admins manage topics" on public.topics for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "Admins manage materials" on public.study_materials for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "Admins manage tests" on public.mock_tests for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "Admins manage test questions" on public.mock_test_questions for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "Admins manage progress" on public.student_progress for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

-- Scoring/progress writes should move to security-definer RPCs in the exam-engine phase.
