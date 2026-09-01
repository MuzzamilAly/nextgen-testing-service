-- Concurrency hardening for simultaneous student test sessions.
with ranked as (
  select id,row_number() over(partition by student_id,mock_test_id order by started_at desc,id desc) as position
  from public.exam_attempts where status='in_progress'
)
update public.exam_attempts set status='abandoned'
where id in(select id from ranked where position>1);

create unique index one_active_attempt_per_test
on public.exam_attempts(student_id,mock_test_id)
where status='in_progress';

create or replace function public.start_mock_test(p_mock_test_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid();v_attempt public.exam_attempts;v_test public.mock_tests;v_questions jsonb;v_total integer;
begin
  if v_user is null then raise exception 'Authentication required';end if;
  select * into v_test from public.mock_tests where id=p_mock_test_id and status='published';
  if not found then raise exception 'Test is not available';end if;
  select count(*) into v_total from public.mock_test_questions where mock_test_id=v_test.id;
  if v_total=0 then raise exception 'Test has no questions';end if;
  insert into public.exam_attempts(student_id,mock_test_id,total_questions)
  values(v_user,v_test.id,v_total)
  on conflict(student_id,mock_test_id) where status='in_progress'
  do update set student_id=excluded.student_id
  returning * into v_attempt;
  select coalesce(jsonb_agg(jsonb_build_object('id',q.id,'question_text',q.question_text,'option_a',q.option_a,'option_b',q.option_b,'option_c',q.option_c,'option_d',q.option_d,'question_order',mtq.question_order) order by mtq.question_order),'[]'::jsonb) into v_questions
  from public.mock_test_questions mtq join public.questions q on q.id=mtq.question_id where mtq.mock_test_id=v_test.id;
  return jsonb_build_object('attempt_id',v_attempt.id,'started_at',v_attempt.started_at,'test',jsonb_build_object('id',v_test.id,'name',v_test.name,'description',v_test.description,'question_count',v_total,'duration_minutes',v_test.duration_minutes,'passing_percentage',v_test.passing_percentage),'questions',v_questions);
end;$$;

create or replace function public.submit_mock_test(p_attempt_id uuid,p_answers jsonb,p_time_used_seconds integer default 0)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid();v_attempt public.exam_attempts;v_item jsonb;v_question uuid;v_selected public.answer_option;v_correct integer:=0;v_answered integer:=0;v_total integer;v_percentage numeric(5,2);v_passing numeric(5,2);
begin
  if v_user is null then raise exception 'Authentication required';end if;
  select * into v_attempt from public.exam_attempts where id=p_attempt_id and student_id=v_user for update;
  if not found then raise exception 'Attempt not found';end if;
  select passing_percentage into v_passing from public.mock_tests where id=v_attempt.mock_test_id;
  if v_attempt.status='submitted' then return jsonb_build_object('attempt_id',v_attempt.id,'total_questions',v_attempt.total_questions,'correct_answers',v_attempt.correct_answers,'incorrect_answers',v_attempt.incorrect_answers,'unanswered',v_attempt.unanswered,'score',v_attempt.score,'percentage',v_attempt.percentage,'passed',v_attempt.percentage>=v_passing);end if;
  if v_attempt.status<>'in_progress' then raise exception 'Attempt is no longer active';end if;
  perform set_config('app.secure_scoring','true',true);
  for v_item in select * from jsonb_array_elements(coalesce(p_answers,'[]'::jsonb)) loop
    v_question:=(v_item->>'question_id')::uuid;v_selected:=(v_item->>'selected_answer')::public.answer_option;
    if exists(select 1 from public.mock_test_questions where mock_test_id=v_attempt.mock_test_id and question_id=v_question) then insert into public.attempt_answers(attempt_id,question_id,selected_answer,is_correct) select v_attempt.id,q.id,v_selected,(q.correct_answer=v_selected) from public.questions q where q.id=v_question on conflict(attempt_id,question_id) do update set selected_answer=excluded.selected_answer,is_correct=excluded.is_correct,answered_at=now();end if;
  end loop;
  select count(*),count(*) filter(where aa.is_correct) into v_answered,v_correct from public.attempt_answers aa where aa.attempt_id=v_attempt.id;
  v_total:=v_attempt.total_questions;v_percentage:=case when v_total>0 then round((v_correct::numeric/v_total::numeric)*100,2) else 0 end;
  update public.exam_attempts set status='submitted',submitted_at=now(),correct_answers=v_correct,incorrect_answers=v_answered-v_correct,unanswered=v_total-v_answered,score=v_correct,percentage=v_percentage,time_used_seconds=greatest(0,p_time_used_seconds) where id=v_attempt.id;
  return jsonb_build_object('attempt_id',v_attempt.id,'total_questions',v_total,'correct_answers',v_correct,'incorrect_answers',v_answered-v_correct,'unanswered',v_total-v_answered,'score',v_correct,'percentage',v_percentage,'passed',v_percentage>=v_passing);
end;$$;

revoke all on function public.start_mock_test(uuid) from public;
revoke all on function public.submit_mock_test(uuid,jsonb,integer) from public;
grant execute on function public.start_mock_test(uuid) to authenticated;
grant execute on function public.submit_mock_test(uuid,jsonb,integer) to authenticated;
