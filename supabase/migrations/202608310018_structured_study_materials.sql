alter table public.study_materials drop constraint if exists study_materials_resource_type_check;
alter table public.study_materials add constraint study_materials_resource_type_check check(resource_type in('chapter_notes','short_notes','formula_sheet','key_concepts','definitions','solved_numericals','important_diagrams','tricks_shortcuts','common_mistakes','topic_mcqs','past_paper_questions','video_lecture','downloadable_pdf','revision_sheet','flashcards','concept_notes','solved_examples'));
alter table public.study_materials add column if not exists difficulty public.question_difficulty;
alter table public.study_materials add column if not exists estimated_minutes integer check(estimated_minutes is null or estimated_minutes>0);
alter table public.study_materials add column if not exists access_tier text not null default 'free' check(access_tier in('free','premium'));
alter table public.study_materials add column if not exists file_url text;
alter table public.study_materials add column if not exists is_downloadable boolean not null default false;

create table if not exists public.study_material_universities(material_id uuid not null references public.study_materials(id) on delete cascade,university_id uuid not null references public.universities(id) on delete cascade,created_at timestamptz not null default now(),primary key(material_id,university_id));
create table if not exists public.study_material_programs(material_id uuid not null references public.study_materials(id) on delete cascade,program_id uuid not null references public.programs(id) on delete cascade,created_at timestamptz not null default now(),primary key(material_id,program_id));
create table if not exists public.study_material_entry_tests(material_id uuid not null references public.study_materials(id) on delete cascade,entry_test_id uuid not null references public.entry_tests(id) on delete cascade,created_at timestamptz not null default now(),primary key(material_id,entry_test_id));
create table if not exists public.study_material_progress(student_id uuid not null references public.profiles(id) on delete cascade,material_id uuid not null references public.study_materials(id) on delete cascade,completed boolean not null default false,completed_at timestamptz,last_viewed_at timestamptz not null default now(),created_at timestamptz not null default now(),updated_at timestamptz not null default now(),primary key(student_id,material_id));
alter table public.study_material_universities enable row level security;
alter table public.study_material_programs enable row level security;
alter table public.study_material_entry_tests enable row level security;
alter table public.study_material_progress enable row level security;
drop policy if exists "Published material universities readable" on public.study_material_universities;
create policy "Published material universities readable" on public.study_material_universities for select to anon,authenticated using(exists(select 1 from public.study_materials m where m.id=material_id and m.status='published'));
drop policy if exists "Admins manage material universities" on public.study_material_universities;
create policy "Admins manage material universities" on public.study_material_universities for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
drop policy if exists "Published material programs readable" on public.study_material_programs;
create policy "Published material programs readable" on public.study_material_programs for select to anon,authenticated using(exists(select 1 from public.study_materials m where m.id=material_id and m.status='published'));
drop policy if exists "Admins manage material programs" on public.study_material_programs;
create policy "Admins manage material programs" on public.study_material_programs for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
drop policy if exists "Published material entry tests readable" on public.study_material_entry_tests;
create policy "Published material entry tests readable" on public.study_material_entry_tests for select to anon,authenticated using(exists(select 1 from public.study_materials m where m.id=material_id and m.status='published'));
drop policy if exists "Admins manage material entry tests" on public.study_material_entry_tests;
create policy "Admins manage material entry tests" on public.study_material_entry_tests for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
drop policy if exists "Students read own material progress" on public.study_material_progress;
create policy "Students read own material progress" on public.study_material_progress for select to authenticated using(student_id=(select auth.uid()) or (select public.is_admin()));
drop policy if exists "Students create own material progress" on public.study_material_progress;
create policy "Students create own material progress" on public.study_material_progress for insert to authenticated with check(student_id=(select auth.uid()));
drop policy if exists "Students update own material progress" on public.study_material_progress;
create policy "Students update own material progress" on public.study_material_progress for update to authenticated using(student_id=(select auth.uid())) with check(student_id=(select auth.uid()));
drop trigger if exists study_material_progress_set_updated_at on public.study_material_progress;
create trigger study_material_progress_set_updated_at before update on public.study_material_progress for each row execute function public.set_updated_at();
create index if not exists study_material_filter_idx on public.study_materials(subject_id,chapter_id,difficulty,access_tier,resource_type,status);

update public.study_materials m set chapter_id=coalesce(m.chapter_id,(select c.id from public.chapters c where c.subject_id=m.subject_id and c.status='published' order by c.name limit 1)),difficulty=coalesce(m.difficulty,'medium'),estimated_minutes=coalesce(m.estimated_minutes,12),resource_type=case when lower(m.title) like '%formula%' then 'formula_sheet' when lower(m.title) like '%question%' then 'topic_mcqs' when lower(m.title) like '%revision%' then 'revision_sheet' else 'chapter_notes' end,access_tier=coalesce(m.access_tier,'free') where m.status='published';
update public.study_materials m set topic_id=coalesce(m.topic_id,(select t.id from public.topics t where t.chapter_id=m.chapter_id and t.status='published' order by t.name limit 1)) where m.status='published' and m.chapter_id is not null;

drop policy if exists "Published materials are publicly readable" on public.study_materials;
create policy "Authorized materials are readable" on public.study_materials for select to anon,authenticated using(status='published' and (access_tier='free' or (select public.is_admin()) or (select public.has_active_subscription())));
create or replace function public.list_study_material_catalog()
returns table(id uuid,subject_id uuid,chapter_id uuid,topic_id uuid,title text,description text,resource_type text,difficulty public.question_difficulty,estimated_minutes integer,access_tier text,file_url text,video_url text,is_downloadable boolean)
language sql stable security definer set search_path='' as $$ select m.id,m.subject_id,m.chapter_id,m.topic_id,m.title,m.description,m.resource_type,m.difficulty,m.estimated_minutes,m.access_tier,m.file_url,m.video_url,m.is_downloadable from public.study_materials m where m.status='published' order by m.created_at desc limit 100; $$;
grant execute on function public.list_study_material_catalog() to anon,authenticated;
