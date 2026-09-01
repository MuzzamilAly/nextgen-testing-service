-- Starter content is stored in PostgreSQL, never in React components.
insert into public.study_materials (subject_id, title, description, content, status)
select id, 'Biology Foundations: Cells', 'A concise introduction to cell structure and function.',
  'The cell is the basic structural and functional unit of life.

Cell membrane: controls movement of substances into and out of the cell.
Nucleus: stores genetic material and coordinates cell activities.
Mitochondria: release usable energy through cellular respiration.
Ribosomes: build proteins from amino acids.

Focus for admission tests: compare plant and animal cells, understand organelle functions, and distinguish prokaryotic cells from eukaryotic cells.', 'published'
from public.subjects where slug = 'biology';

insert into public.study_materials (subject_id, title, description, content, status)
select id, 'Chemistry Foundations: Atomic Structure', 'Review the particles and organization of an atom.',
  'Atoms contain protons, neutrons and electrons.

Protons carry a positive charge and determine the atomic number.
Neutrons have no electrical charge and contribute to atomic mass.
Electrons carry a negative charge and occupy energy levels around the nucleus.

Focus for admission tests: calculate protons, neutrons and electrons; recognize isotopes; and understand electron arrangement.', 'published'
from public.subjects where slug = 'chemistry';

insert into public.study_materials (subject_id, title, description, content, status)
select id, 'Physics Foundations: Motion', 'Understand speed, velocity and acceleration.',
  'Motion describes a change in position over time.

Speed = distance divided by time.
Velocity is speed in a specified direction.
Acceleration is the rate at which velocity changes.

Focus for admission tests: use consistent SI units, distinguish scalar and vector quantities, and interpret simple distance-time and velocity-time graphs.', 'published'
from public.subjects where slug = 'physics';

insert into public.study_materials (subject_id, title, description, content, status)
select id, 'English Foundations: Reading Comprehension', 'Use an evidence-based approach to short passages.',
  'Begin by identifying the central idea of the passage. Separate facts stated by the writer from conclusions that must be inferred.

For vocabulary questions, use the surrounding sentence to determine meaning in context. For inference questions, select the option best supported by the passage rather than outside knowledge.

Focus for admission tests: central idea, supporting detail, contextual vocabulary, tone and logical inference.', 'published'
from public.subjects where slug = 'english';

insert into public.questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty, source, status)
select id, 'Which organelle is primarily responsible for producing usable energy in a eukaryotic cell?', 'Nucleus', 'Mitochondrion', 'Ribosome', 'Golgi apparatus', 'b', 'Mitochondria generate ATP during cellular respiration.', 'easy', 'NEXTGEN starter biology 1', 'published' from public.subjects where slug='biology';
insert into public.questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty, source, status)
select id, 'Which subatomic particle determines the atomic number of an element?', 'Electron', 'Neutron', 'Proton', 'Photon', 'c', 'The atomic number equals the number of protons in the nucleus.', 'easy', 'NEXTGEN starter chemistry 1', 'published' from public.subjects where slug='chemistry';
insert into public.questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty, source, status)
select id, 'A student travels 120 metres in 30 seconds. What is the average speed?', '2 m/s', '4 m/s', '30 m/s', '90 m/s', 'b', 'Average speed equals distance divided by time: 120 / 30 = 4 m/s.', 'easy', 'NEXTGEN starter physics 1', 'published' from public.subjects where slug='physics';
insert into public.questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty, source, status)
select id, 'Choose the grammatically correct sentence.', 'She have completed the test.', 'She has completed the test.', 'She completed has the test.', 'She having completed the test.', 'b', 'The singular subject “She” takes the auxiliary verb “has.”', 'easy', 'NEXTGEN starter english 1', 'published' from public.subjects where slug='english';

insert into public.mock_tests (name, description, question_count, duration_minutes, passing_percentage, status, assessment_type)
values ('NEXTGEN Foundation Diagnostic', 'A short diagnostic covering Biology, Chemistry, Physics and English foundations.', 4, 8, 50, 'published', 'practice_quiz');

insert into public.mock_test_questions (mock_test_id, question_id, question_order)
select t.id, q.id, row_number() over (order by q.source)::integer
from public.mock_tests t
join public.questions q on q.source like 'NEXTGEN starter % 1'
where t.name = 'NEXTGEN Foundation Diagnostic';
