create table if not exists public.entry_tests (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  short_name text,
  overview text,
  who_should_take text,
  eligibility text,
  syllabus text[] not null default '{}',
  paper_pattern text,
  subject_weightage jsonb not null default '{}'::jsonb,
  total_questions integer check (total_questions is null or total_questions > 0),
  total_marks integer check (total_marks is null or total_marks > 0),
  duration_minutes integer check (duration_minutes is null or duration_minutes > 0),
  negative_marking text,
  difficulty_level text,
  preparation_weeks integer check (preparation_weeks is null or preparation_weeks > 0),
  preparation_schedule text[] not null default '{}',
  official_url text,
  status public.content_status not null default 'draft',
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.entry_test_universities (entry_test_id uuid not null references public.entry_tests(id) on delete cascade,university_id uuid not null references public.universities(id) on delete cascade,created_at timestamptz not null default now(),primary key(entry_test_id,university_id));
create table if not exists public.entry_test_programs (entry_test_id uuid not null references public.entry_tests(id) on delete cascade,program_id uuid not null references public.programs(id) on delete cascade,created_at timestamptz not null default now(),primary key(entry_test_id,program_id));
create table if not exists public.entry_test_mock_tests (entry_test_id uuid not null references public.entry_tests(id) on delete cascade,mock_test_id uuid not null references public.mock_tests(id) on delete cascade,resource_type text not null default 'full_mock' check(resource_type in ('topic_test','full_mock','past_paper')),created_at timestamptz not null default now(),primary key(entry_test_id,mock_test_id));
alter table public.entry_tests enable row level security;
alter table public.entry_test_universities enable row level security;
alter table public.entry_test_programs enable row level security;
alter table public.entry_test_mock_tests enable row level security;
drop policy if exists "Published entry tests are readable" on public.entry_tests;
create policy "Published entry tests are readable" on public.entry_tests for select to anon,authenticated using(status='published' or (select public.is_admin()));
drop policy if exists "Admins manage entry tests" on public.entry_tests;
create policy "Admins manage entry tests" on public.entry_tests for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
drop policy if exists "Published entry test universities are readable" on public.entry_test_universities;
create policy "Published entry test universities are readable" on public.entry_test_universities for select to anon,authenticated using(exists(select 1 from public.entry_tests e where e.id=entry_test_id and e.status='published'));
drop policy if exists "Admins manage entry test universities" on public.entry_test_universities;
create policy "Admins manage entry test universities" on public.entry_test_universities for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
drop policy if exists "Published entry test programs are readable" on public.entry_test_programs;
create policy "Published entry test programs are readable" on public.entry_test_programs for select to anon,authenticated using(exists(select 1 from public.entry_tests e where e.id=entry_test_id and e.status='published'));
drop policy if exists "Admins manage entry test programs" on public.entry_test_programs;
create policy "Admins manage entry test programs" on public.entry_test_programs for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
drop policy if exists "Published entry test resources are readable" on public.entry_test_mock_tests;
create policy "Published entry test resources are readable" on public.entry_test_mock_tests for select to anon,authenticated using(exists(select 1 from public.entry_tests e where e.id=entry_test_id and e.status='published'));
drop policy if exists "Admins manage entry test resources" on public.entry_test_mock_tests;
create policy "Admins manage entry test resources" on public.entry_test_mock_tests for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));
drop trigger if exists entry_tests_set_updated_at on public.entry_tests;
create trigger entry_tests_set_updated_at before update on public.entry_tests for each row execute function public.set_updated_at();

insert into public.entry_tests(name,slug,short_name,overview,who_should_take,eligibility,syllabus,paper_pattern,negative_marking,difficulty_level,preparation_weeks,preparation_schedule,official_url,status,last_verified_at) values
('NUST Entry Test','nust-net','NET','Institutional undergraduate admission assessment used by NUST for relevant programme routes.','Students applying to NUST undergraduate programmes through the NET route.','Programme and qualification requirements vary. Confirm the current NUST undergraduate eligibility policy.','{"Mathematics or Biology","Physics","Chemistry or Computer Science","English","Intelligence"}','Discipline-specific multiple-choice sections; use the current official subject-weighting page.','Confirm the current official NET policy.','Competitive',12,'{"Complete a diagnostic","Revise required subjects","Practice timed topic sets","Attempt full-length mocks","Review errors before the test"}','https://ugadmissions.nust.edu.pk/','published',now()),
('FAST-NUCES Admission Test','fast-nu-test','FAST NU Test','Admission assessment used for relevant FAST-NUCES undergraduate routes.','Applicants choosing the university admission-test route for FAST-NUCES programmes.','Eligibility and accepted test routes depend on the selected degree.','{"Advanced Mathematics","Basic Mathematics","Analytical Skills","English"}','Computer-based or institution-defined aptitude sections depending on programme.','Confirm the current official policy.','Competitive',10,'{"Strengthen mathematics","Build analytical speed","Practice English MCQs","Complete timed mocks"}','https://admissions.nu.edu.pk/','published',now()),
('National Aptitude Test','nts-nat','NTS NAT','General undergraduate aptitude test accepted by participating institutions and programmes.','Students applying to institutions that accept the relevant NAT category.','Choose the NAT category matching your academic background and target programme.','{"English","Analytical Reasoning","Quantitative Reasoning","Subject Knowledge"}','Category-based multiple-choice aptitude and subject sections.','Verify the current NTS test specification.','Moderate to competitive',8,'{"Choose the correct NAT category","Review aptitude foundations","Practice subject MCQs","Attempt timed tests"}','https://www.nts.org.pk/','published',now()),
('Graduate Assessment Test','nts-gat','NTS GAT','Graduate-level aptitude assessment used by participating programmes and institutions.','Graduate applicants whose target programme requires or accepts GAT.','Qualification and minimum score requirements are programme-specific.','{"Verbal Reasoning","Quantitative Reasoning","Analytical Reasoning"}','Category-specific graduate aptitude sections.','Verify the current NTS specification.','Competitive',8,'{"Take a diagnostic","Review quantitative concepts","Practice verbal and analytical sets","Attempt full mocks"}','https://www.nts.org.pk/','published',now()),
('Engineering College Admission Test','ecat','ECAT','Engineering admission assessment associated with UET and participating routes.','Students targeting engineering and technology programmes that require ECAT.','Academic subject combinations and domicile or category rules vary; verify the current guide.','{"Mathematics","Physics","Chemistry or Computer Science","English"}','Multiple-choice science, mathematics and English sections according to the current combination.','Confirm the current ECAT rules.','Competitive',12,'{"Review mathematics and physics","Complete chemistry or computing revision","Practice speed MCQs","Attempt full ECAT mocks"}','https://admission.uet.edu.pk/','published',now()),
('Medical and Dental College Admission Test','mdcat','MDCAT','Medical and dental admission preparation pathway based on the current national or provincial framework.','Applicants to medical and dental programmes where MDCAT is required.','Eligibility and admission rules are defined by current regulators and institutions.','{"Biology","Chemistry","Physics","English","Logical Reasoning"}','The official blueprint defines question distribution and cognitive difficulty.','Verify the current official blueprint.','Highly competitive',16,'{"Master biology foundations","Revise chemistry and physics","Practice logical reasoning","Complete regular timed mocks","Review official updates"}','https://pmdc.pk/','published',now()),
('GIKI Admission Test','giki-admission-test','GIKI Test','Undergraduate admission assessment for relevant GIKI programmes.','Students applying to GIKI undergraduate engineering, computing or science pathways.','Programme-specific academic requirements apply.','{"Mathematics","Physics","English or Aptitude"}','Review the current GIKI undergraduate test guidance.','Confirm the current official policy.','Competitive',10,'{"Strengthen mathematics","Revise physics","Practice aptitude and English","Attempt timed full mocks"}','https://admissions.giki.edu.pk/','published',now()),
('PIEAS Entry Test','pieas-entry-test','PIEAS Test','Written admission assessment for relevant PIEAS undergraduate programmes.','Students applying to PIEAS BS engineering, computing or science programmes.','Review the current PIEAS BS information leaflet.','{"Mathematics or Biology","Physics","Chemistry or Computer Science","English"}','Programme-group multiple-choice test; confirm the current official pattern.','Verify on the official admissions site.','Highly competitive',12,'{"Review the BS test pattern","Revise core subjects","Practice calculation speed","Attempt full mocks"}','https://admissions.pieas.edu.pk/','published',now()),
('COMSATS / NTS Admission Test','comsats-nts-test','COMSATS / NTS','Admission test route used by COMSATS programmes, often through the relevant NTS category.','Applicants to COMSATS programmes requiring an accepted admission-test score.','Campus, programme and test-category requirements vary.','{"English","Analytical Reasoning","Quantitative Reasoning","Subject Knowledge"}','NTS category or campus-defined format according to the selected programme.','Verify the current test category rules.','Competitive',8,'{"Confirm the required test category","Review aptitude skills","Revise subject content","Attempt timed NAT-style mocks"}','https://admissions.comsats.edu.pk/','published',now()),
('LUMS SAT-based Admission','lums-sat-admission','LUMS SAT Route','SAT-based application route used by relevant LUMS undergraduate programmes.','Applicants whose selected LUMS programme accepts or requires SAT results.','School, programme and application-cycle requirements vary.','{"Reading and Writing","Mathematics"}','Use the current College Board SAT format and the selected LUMS programme requirements.','SAT scoring rules apply; confirm current requirements.','Competitive',12,'{"Take an official-style diagnostic","Build reading and grammar accuracy","Strengthen mathematics","Complete timed full tests","Prepare the wider application"}','https://admissions.lums.edu.pk/','published',now())
on conflict(slug) do update set name=excluded.name,short_name=excluded.short_name,overview=excluded.overview,who_should_take=excluded.who_should_take,eligibility=excluded.eligibility,syllabus=excluded.syllabus,paper_pattern=excluded.paper_pattern,negative_marking=excluded.negative_marking,difficulty_level=excluded.difficulty_level,preparation_weeks=excluded.preparation_weeks,preparation_schedule=excluded.preparation_schedule,official_url=excluded.official_url,status=excluded.status,last_verified_at=excluded.last_verified_at,updated_at=now();

insert into public.entry_test_universities(entry_test_id,university_id)
select e.id,u.id from public.entry_tests e join public.universities u on (e.slug,u.slug) in (('nust-net','nust'),('fast-nu-test','fast-nuces'),('ecat','uet-lahore'),('giki-admission-test','giki'),('pieas-entry-test','pieas'),('comsats-nts-test','comsats'),('lums-sat-admission','lums')) on conflict do nothing;
