-- Core learning pack: educational records remain database-managed.
insert into public.study_materials (subject_id,title,description,content,status)
select id,'Biology: Human Circulatory System','Understand blood flow, the heart and major blood components.','The circulatory system transports oxygen, nutrients, hormones and waste products. The heart has four chambers: right atrium, right ventricle, left atrium and left ventricle. The right side sends deoxygenated blood to the lungs; the left side sends oxygenated blood to the body. Arteries carry blood away from the heart, veins return blood, and capillaries allow exchange with tissues. Red blood cells transport oxygen, white blood cells support immunity, platelets help clotting, and plasma carries dissolved substances.','published' from public.subjects where slug='biology';
insert into public.study_materials (subject_id,title,description,content,status)
select id,'Chemistry: Chemical Bonding','Review ionic, covalent and metallic bonding.','Chemical bonds form when atoms achieve more stable electron arrangements. Ionic bonding involves electron transfer and attraction between oppositely charged ions. Covalent bonding involves shared electron pairs, commonly between non-metals. Metallic bonding consists of positive metal ions surrounded by delocalized electrons. Bond type influences melting point, electrical conductivity, solubility and physical strength.','published' from public.subjects where slug='chemistry';
insert into public.study_materials (subject_id,title,description,content,status)
select id,'Physics: Work, Energy and Power','Learn the core relationships used in numerical problems.','Work is done when a force causes displacement in its direction: work = force × distance. Energy is the capacity to do work. Kinetic energy depends on mass and velocity, while gravitational potential energy depends on mass, gravitational field strength and height. Power is the rate of energy transfer: power = work divided by time. The SI unit of work and energy is the joule; the SI unit of power is the watt.','published' from public.subjects where slug='physics';
insert into public.study_materials (subject_id,title,description,content,status)
select id,'English: Grammar and Sentence Agreement','Strengthen subject–verb agreement and sentence accuracy.','A verb must agree with its subject in number. A singular subject normally takes a singular verb, while a plural subject takes a plural verb. Words between the subject and verb do not change agreement. Indefinite pronouns such as each, everyone and neither are generally singular. In compound subjects joined by and, use a plural verb. Read the complete sentence before deciding which noun controls the verb.','published' from public.subjects where slug='english';

insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Which chamber pumps oxygenated blood into the aorta?','Right atrium','Right ventricle','Left atrium','Left ventricle','d','The left ventricle pumps oxygenated blood into the systemic circulation through the aorta.','medium','NEXTGEN core biology 2a','published' from public.subjects where slug='biology';
insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Which blood component is primarily responsible for clot formation?','Red blood cells','Platelets','Plasma proteins only','Lymphocytes','b','Platelets aggregate at damaged vessels and participate in the clotting process.','easy','NEXTGEN core biology 2b','published' from public.subjects where slug='biology';
insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Gas exchange between blood and body tissues occurs mainly in which vessels?','Arteries','Veins','Capillaries','Aorta','c','Thin capillary walls allow diffusion between blood and surrounding tissues.','easy','NEXTGEN core biology 2c','published' from public.subjects where slug='biology';

insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'An ionic bond is best described as the attraction between:','Two shared electron pairs','Oppositely charged ions','Two neutral molecules','A proton and neutron','b','Electron transfer produces positive and negative ions that attract electrostatically.','easy','NEXTGEN core chemistry 2a','published' from public.subjects where slug='chemistry';
insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Which substance is most likely to conduct electricity when molten?','An ionic compound','A simple covalent molecule','A noble gas','Pure water only','a','Molten ionic compounds conduct because their ions are free to move.','medium','NEXTGEN core chemistry 2b','published' from public.subjects where slug='chemistry';
insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Covalent bonding usually involves:','Transfer of protons','Sharing of electrons','Loss of neutrons','Formation of free ions only','b','Covalent bonds form through shared pairs of electrons.','easy','NEXTGEN core chemistry 2c','published' from public.subjects where slug='chemistry';

insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'A force of 20 N moves an object 5 m in the force direction. How much work is done?','4 J','25 J','100 J','400 J','c','Work = force × distance = 20 × 5 = 100 J.','easy','NEXTGEN core physics 2a','published' from public.subjects where slug='physics';
insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'A machine performs 600 J of work in 3 seconds. Its power is:','200 W','600 W','1,800 W','0.005 W','a','Power = work / time = 600 / 3 = 200 W.','easy','NEXTGEN core physics 2b','published' from public.subjects where slug='physics';
insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Which change definitely increases kinetic energy?','Reducing speed','Increasing velocity magnitude','Lowering height only','Decreasing mass while speed is zero','b','Kinetic energy increases with the square of speed, so greater velocity magnitude increases it.','medium','NEXTGEN core physics 2c','published' from public.subjects where slug='physics';

insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Choose the correct sentence.','Each of the students are ready.','Each of the students is ready.','Each of the student are ready.','Each students is ready.','b','The indefinite pronoun “each” is singular and takes “is.”','medium','NEXTGEN core english 2a','published' from public.subjects where slug='english';
insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Select the sentence with correct subject–verb agreement.','The list of topics are long.','The list of topics is long.','The list of topic are long.','The lists of topics is long.','b','The subject is the singular noun “list,” so the correct verb is “is.”','medium','NEXTGEN core english 2b','published' from public.subjects where slug='english';
insert into public.questions (subject_id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,difficulty,source,status)
select id,'Which word best completes the sentence: “Neither answer ___ correct.”','are','were','is','have','c','“Neither” is singular in this construction and takes “is.”','easy','NEXTGEN core english 2c','published' from public.subjects where slug='english';

insert into public.mock_tests (name,description,question_count,duration_minutes,passing_percentage,status,assessment_type)
values ('Science Mini Mock','Nine focused questions across Biology, Chemistry and Physics.',9,15,55,'published','mock_test');
insert into public.mock_test_questions (mock_test_id,question_id,question_order)
select t.id,q.id,row_number() over(order by q.source)::integer from public.mock_tests t join public.questions q on q.source like 'NEXTGEN core % 2%' and q.source not like '%english%' where t.name='Science Mini Mock';

insert into public.mock_tests (name,description,question_count,duration_minutes,passing_percentage,status,assessment_type)
values ('English Skills Quiz','Three focused questions on grammar and subject–verb agreement.',3,6,60,'published','practice_quiz');
insert into public.mock_test_questions (mock_test_id,question_id,question_order)
select t.id,q.id,row_number() over(order by q.source)::integer from public.mock_tests t join public.questions q on q.source like 'NEXTGEN core english 2%' where t.name='English Skills Quiz';
