create or replace function public.save_attempt_answer(p_attempt_id uuid,p_question_id uuid,p_selected_answer public.answer_option)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid();v_attempt public.exam_attempts;v_duration integer;
begin
  if v_user is null then raise exception 'Authentication required';end if;
  select a.* into v_attempt from public.exam_attempts a where a.id=p_attempt_id and a.student_id=v_user for update;
  if not found or v_attempt.status<>'in_progress' then raise exception 'Attempt is no longer active';end if;
  select duration_minutes into v_duration from public.mock_tests where id=v_attempt.mock_test_id;
  if now()>v_attempt.started_at+make_interval(mins=>v_duration)+interval '30 seconds' then raise exception 'TEST_TIME_EXPIRED';end if;
  if not exists(select 1 from public.mock_test_questions mtq where mtq.mock_test_id=v_attempt.mock_test_id and mtq.question_id=p_question_id) then raise exception 'Question does not belong to this test';end if;
  perform set_config('app.secure_scoring','true',true);
  insert into public.attempt_answers(attempt_id,question_id,selected_answer,is_correct,answered_at) values(v_attempt.id,p_question_id,p_selected_answer,null,now()) on conflict(attempt_id,question_id) do update set selected_answer=excluded.selected_answer,is_correct=null,answered_at=now();
  return jsonb_build_object('saved',true,'answered_at',now());
end;$$;

create or replace function public.start_mock_test(p_mock_test_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid();v_attempt public.exam_attempts;v_test public.mock_tests;v_questions jsonb;v_saved jsonb;v_total integer;
begin
  if v_user is null then raise exception 'Authentication required';end if;
  if not public.is_admin() and not public.has_active_subscription(v_user) then raise exception 'SUBSCRIPTION_REQUIRED: Please activate a subscription before starting a test';end if;
  select * into v_test from public.mock_tests where id=p_mock_test_id and status='published';if not found then raise exception 'Test is not available';end if;
  select count(*) into v_total from public.mock_test_questions where mock_test_id=v_test.id;if v_total=0 then raise exception 'Test has no questions';end if;
  insert into public.exam_attempts(student_id,mock_test_id,total_questions) values(v_user,v_test.id,v_total) on conflict(student_id,mock_test_id) where status='in_progress' do update set student_id=excluded.student_id returning * into v_attempt;
  select coalesce(jsonb_agg(jsonb_build_object('id',q.id,'question_text',q.question_text,'option_a',q.option_a,'option_b',q.option_b,'option_c',q.option_c,'option_d',q.option_d,'question_order',mtq.question_order) order by mtq.question_order),'[]'::jsonb) into v_questions from public.mock_test_questions mtq join public.questions q on q.id=mtq.question_id where mtq.mock_test_id=v_test.id and q.status='published';
  select coalesce(jsonb_object_agg(aa.question_id::text,aa.selected_answer::text),'{}'::jsonb) into v_saved from public.attempt_answers aa where aa.attempt_id=v_attempt.id and aa.selected_answer is not null;
  return jsonb_build_object('attempt_id',v_attempt.id,'started_at',v_attempt.started_at,'server_now',now(),'deadline_at',v_attempt.started_at+make_interval(mins=>v_test.duration_minutes),'saved_answers',v_saved,'test',jsonb_build_object('id',v_test.id,'name',v_test.name,'description',v_test.description,'question_count',v_total,'duration_minutes',v_test.duration_minutes,'passing_percentage',v_test.passing_percentage),'questions',v_questions);
end;$$;

create or replace function public.submit_mock_test(p_attempt_id uuid,p_answers jsonb,p_time_used_seconds integer default 0)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid();v_attempt public.exam_attempts;v_item jsonb;v_question uuid;v_selected public.answer_option;v_correct integer:=0;v_answered integer:=0;v_total integer;v_percentage numeric(5,2);v_passing numeric(5,2);v_duration integer;v_actual_seconds integer;
begin
  if v_user is null then raise exception 'Authentication required';end if;
  select a.* into v_attempt from public.exam_attempts a where a.id=p_attempt_id and a.student_id=v_user for update;if not found then raise exception 'Attempt not found';end if;
  select passing_percentage,duration_minutes into v_passing,v_duration from public.mock_tests where id=v_attempt.mock_test_id;
  if v_attempt.status='submitted' then return jsonb_build_object('attempt_id',v_attempt.id,'total_questions',v_attempt.total_questions,'correct_answers',v_attempt.correct_answers,'incorrect_answers',v_attempt.incorrect_answers,'unanswered',v_attempt.unanswered,'score',v_attempt.score,'percentage',v_attempt.percentage,'passed',v_attempt.percentage>=v_passing);end if;
  if v_attempt.status<>'in_progress' then raise exception 'Attempt is no longer active';end if;
  perform set_config('app.secure_scoring','true',true);
  for v_item in select * from jsonb_array_elements(coalesce(p_answers,'[]'::jsonb)) loop v_question:=(v_item->>'question_id')::uuid;v_selected:=(v_item->>'selected_answer')::public.answer_option;if exists(select 1 from public.mock_test_questions where mock_test_id=v_attempt.mock_test_id and question_id=v_question) then insert into public.attempt_answers(attempt_id,question_id,selected_answer,is_correct) select v_attempt.id,q.id,v_selected,(q.correct_answer=v_selected) from public.questions q where q.id=v_question on conflict(attempt_id,question_id) do update set selected_answer=excluded.selected_answer,is_correct=excluded.is_correct,answered_at=now();end if;end loop;
  update public.attempt_answers aa set is_correct=(q.correct_answer=aa.selected_answer) from public.questions q where aa.attempt_id=v_attempt.id and q.id=aa.question_id;
  select count(*),count(*) filter(where aa.is_correct) into v_answered,v_correct from public.attempt_answers aa where aa.attempt_id=v_attempt.id and aa.selected_answer is not null;
  v_total:=v_attempt.total_questions;v_percentage:=case when v_total>0 then round((v_correct::numeric/v_total::numeric)*100,2) else 0 end;v_actual_seconds:=least(v_duration*60,greatest(0,extract(epoch from(now()-v_attempt.started_at))::integer));
  update public.exam_attempts set status='submitted',submitted_at=now(),correct_answers=v_correct,incorrect_answers=v_answered-v_correct,unanswered=v_total-v_answered,score=v_correct,percentage=v_percentage,time_used_seconds=v_actual_seconds where id=v_attempt.id;
  return jsonb_build_object('attempt_id',v_attempt.id,'total_questions',v_total,'correct_answers',v_correct,'incorrect_answers',v_answered-v_correct,'unanswered',v_total-v_answered,'score',v_correct,'percentage',v_percentage,'passed',v_percentage>=v_passing,'time_used_seconds',v_actual_seconds);
end;$$;
revoke all on function public.save_attempt_answer(uuid,uuid,public.answer_option) from public;
grant execute on function public.save_attempt_answer(uuid,uuid,public.answer_option) to authenticated;
revoke all on function public.start_mock_test(uuid) from public;
revoke all on function public.submit_mock_test(uuid,jsonb,integer) from public;
grant execute on function public.start_mock_test(uuid) to authenticated;
grant execute on function public.submit_mock_test(uuid,jsonb,integer) to authenticated;
create index if not exists attempt_answers_attempt_lookup on public.attempt_answers(attempt_id,question_id);
