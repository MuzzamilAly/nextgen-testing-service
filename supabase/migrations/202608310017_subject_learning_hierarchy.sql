alter table public.subjects add column if not exists overview text;
alter table public.subjects add column if not exists important_formulas text[] not null default '{}';
alter table public.study_materials add column if not exists resource_type text not null default 'concept_notes' check(resource_type in('concept_notes','formula_sheet','solved_examples','video_lecture'));
alter table public.study_materials add column if not exists video_url text;

insert into public.subjects(name,slug,description,icon,display_order,status,overview,important_formulas) values
('Mathematics','mathematics','Algebra, geometry, trigonometry and quantitative problem solving.','calculator',10,'published','Build mathematical fluency for engineering, computing, business and aptitude admissions.','{"Quadratic formula: x = (-b ± √(b²-4ac)) / 2a","Distance = speed × time","Percentage = part / whole × 100"}'),
('Physics','physics','Mechanics, waves, electricity and applied physics.','atom',20,'published','Understand physical principles and apply them accurately in numerical and conceptual questions.','{"Force = mass × acceleration","Work = force × displacement","Power = work / time","V = IR"}'),
('Chemistry','chemistry','Atomic structure, bonding, reactions and organic chemistry.','flask',30,'published','Develop command of chemical concepts, equations and scientific reasoning.','{"Moles = mass / molar mass","Molarity = moles / volume (L)","pH = -log[H⁺]"}'),
('Biology','biology','Cells, genetics, physiology and life systems.','dna',40,'published','Master biological systems from cellular organization to human physiology and inheritance.','{"Magnification = image size / actual size","Hardy-Weinberg: p² + 2pq + q² = 1"}'),
('Computer Science','computer-science','Computing fundamentals, logic, algorithms and data representation.','code',50,'published','Prepare computing concepts and logical problem solving for technology admissions.','{"Binary place value uses powers of 2","Time complexity describes input-growth cost"}'),
('English','english','Grammar, vocabulary, comprehension and verbal accuracy.','languages',60,'published','Improve reading comprehension, grammar, vocabulary and precise written communication.','{}'),
('Intelligence / IQ','intelligence-iq','Pattern recognition, sequences, spatial and logical intelligence.','brain',70,'published','Build speed and accuracy across verbal, numerical and non-verbal intelligence questions.','{}'),
('Analytical Reasoning','analytical-reasoning','Logic sets, deductions, arrangements and structured reasoning.','route',80,'published','Translate conditions into clear logical structures and solve constraint-based questions.','{}'),
('Quantitative Reasoning','quantitative-reasoning','Arithmetic, ratios, percentages and data interpretation.','chart',90,'published','Apply practical mathematics to aptitude and admission-test problems.','{"Average = sum / count","Ratio a:b = a / b","Simple interest = PRT / 100"}'),
('General Knowledge','general-knowledge','Pakistan studies, science awareness, world knowledge and current affairs.','globe',100,'published','Organize broad factual knowledge and current-awareness preparation.','{}')
on conflict(slug) do update set name=excluded.name,description=excluded.description,icon=excluded.icon,display_order=excluded.display_order,status=excluded.status,overview=excluded.overview,important_formulas=excluded.important_formulas,updated_at=now();

with chapter_data(subject_slug,chapter_name,description) as (values
('mathematics','Algebra and Functions','Expressions, equations and functions.'),('mathematics','Geometry and Trigonometry','Shapes, measurement and trigonometric relationships.'),
('physics','Mechanics','Motion, force, work and energy.'),('physics','Waves and Electricity','Wave behaviour and electrical principles.'),
('chemistry','Atomic Structure and Bonding','Atoms, periodicity and chemical bonds.'),('chemistry','Reactions and Organic Chemistry','Chemical change and carbon compounds.'),
('biology','Cell Biology and Genetics','Cells, division and inheritance.'),('biology','Human Physiology','Major human body systems.'),
('computer-science','Computing Fundamentals','Data, hardware, software and networks.'),('computer-science','Logic and Algorithms','Problem solving and algorithmic thinking.'),
('english','Grammar and Vocabulary','Language rules and word usage.'),('english','Reading Comprehension','Understanding and evaluating passages.'),
('intelligence-iq','Verbal and Numerical Intelligence','Sequences, analogies and classifications.'),('intelligence-iq','Non-verbal Intelligence','Visual patterns and spatial reasoning.'),
('analytical-reasoning','Logic Foundations','Statements, deductions and conditions.'),('analytical-reasoning','Arrangements and Grouping','Ordering, selection and grouping problems.'),
('quantitative-reasoning','Arithmetic and Proportions','Numbers, ratios and percentages.'),('quantitative-reasoning','Data Interpretation','Tables, charts and quantitative comparison.'),
('general-knowledge','Pakistan and World','Civics, geography and major institutions.'),('general-knowledge','Science and Current Awareness','Everyday science and current developments.'))
insert into public.chapters(subject_id,name,description,status)
select s.id,c.chapter_name,c.description,'published' from chapter_data c join public.subjects s on s.slug=c.subject_slug
on conflict(subject_id,name) do update set description=excluded.description,status=excluded.status,updated_at=now();

with topic_data(subject_slug,chapter_name,topic_name,description) as (values
('mathematics','Algebra and Functions','Linear and Quadratic Equations','Solve and interpret common equations.'),('mathematics','Geometry and Trigonometry','Triangles and Trigonometric Ratios','Apply geometric and trigonometric relationships.'),
('physics','Mechanics','Motion and Newton Laws','Analyze motion, force and acceleration.'),('physics','Waves and Electricity','Waves, Current and Resistance','Review wave properties and electric circuits.'),
('chemistry','Atomic Structure and Bonding','Atoms and Chemical Bonds','Understand particles, orbitals and bonding.'),('chemistry','Reactions and Organic Chemistry','Reactions and Functional Groups','Classify reactions and organic compounds.'),
('biology','Cell Biology and Genetics','Cells, Mitosis and Inheritance','Connect cell function, division and genetics.'),('biology','Human Physiology','Circulation and Respiration','Study transport and gas exchange systems.'),
('computer-science','Computing Fundamentals','Data Representation and Networks','Review binary data and communication basics.'),('computer-science','Logic and Algorithms','Algorithms and Flow Control','Trace algorithms and control structures.'),
('english','Grammar and Vocabulary','Sentence Agreement and Word Choice','Improve grammatical and vocabulary accuracy.'),('english','Reading Comprehension','Main Idea and Inference','Read for evidence, purpose and implication.'),
('intelligence-iq','Verbal and Numerical Intelligence','Series and Analogies','Identify numerical and verbal relationships.'),('intelligence-iq','Non-verbal Intelligence','Patterns and Spatial Rotation','Recognize visual transformations.'),
('analytical-reasoning','Logic Foundations','Statements and Deductions','Derive valid conclusions from conditions.'),('analytical-reasoning','Arrangements and Grouping','Ordering and Selection Sets','Model and solve constrained arrangements.'),
('quantitative-reasoning','Arithmetic and Proportions','Ratios, Percentages and Averages','Solve common quantitative aptitude problems.'),('quantitative-reasoning','Data Interpretation','Tables and Charts','Extract and compare quantitative information.'),
('general-knowledge','Pakistan and World','Pakistan, Geography and Institutions','Review key national and international facts.'),('general-knowledge','Science and Current Awareness','Everyday Science and Current Events','Build structured general awareness.'))
insert into public.topics(chapter_id,name,description,status)
select c.id,t.topic_name,t.description,'published' from topic_data t join public.subjects s on s.slug=t.subject_slug join public.chapters c on c.subject_id=s.id and c.name=t.chapter_name
on conflict(chapter_id,name) do update set description=excluded.description,status=excluded.status,updated_at=now();
