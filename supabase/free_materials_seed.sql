-- NEXTGEN free downloadable PDFs.
-- Safe to run more than once: existing records are skipped by file_url.
with materials(subject_name, title, description, content, resource_type, difficulty, estimated_minutes, file_url) as (
  values
    ('Physics', 'Physics Class 11 Book', 'Class 11 Physics textbook for medical and university admission preparation.', 'Read the complete Class 11 Physics book online or download the PDF for revision.', 'downloadable_pdf', 'medium'::public.question_difficulty, 240, '/materials/physics-11.pdf'),
    ('Chemistry', 'Chemistry Class 11 Book', 'Class 11 Chemistry textbook covering foundational admission-test concepts.', 'Read the complete Class 11 Chemistry book online or download the PDF for revision.', 'downloadable_pdf', 'medium'::public.question_difficulty, 240, '/materials/chemistry-11.pdf'),
    ('Biology', 'Biology Class 11 Book', 'Class 11 Biology textbook for medical and healthcare admission preparation.', 'Read the complete Class 11 Biology book online or download the PDF for revision.', 'downloadable_pdf', 'medium'::public.question_difficulty, 240, '/materials/biology-11.pdf'),
    ('Biology', 'Dow Medical Admission Past Papers', 'Past-paper collection for focused medical admission-test practice.', 'Use these past papers to understand question patterns and practise under exam conditions.', 'past_paper_questions', 'hard'::public.question_difficulty, 300, '/materials/dow-medical-past-papers.pdf')
)
insert into public.study_materials (
  subject_id,
  title,
  description,
  content,
  resource_type,
  difficulty,
  estimated_minutes,
  access_tier,
  file_url,
  is_downloadable,
  status
)
select
  s.id,
  m.title,
  m.description,
  m.content,
  m.resource_type,
  m.difficulty,
  m.estimated_minutes,
  'free',
  m.file_url,
  true,
  'published'
from materials m
join public.subjects s on lower(s.name) = lower(m.subject_name)
where not exists (
  select 1
  from public.study_materials existing
  where existing.file_url = m.file_url
);

select title, access_tier, file_url, status
from public.study_materials
where file_url in (
  '/materials/physics-11.pdf',
  '/materials/chemistry-11.pdf',
  '/materials/biology-11.pdf',
  '/materials/dow-medical-past-papers.pdf'
)
order by title;
