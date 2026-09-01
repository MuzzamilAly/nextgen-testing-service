-- Secure exam delivery and grading. Correct answers never leave the database before grading.
create or replace function public.start_mock_test(p_mock_test_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid(); v_attempt public.exam_attempts; v_test public.mock_tests; v_questions jsonb;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  select * into v_test from public.mock_tests where id=p_mock_test_id and status='published';
  if not found then raise exception 'Test is not available'; end if;
  insert into public.exam_attempts(student_id,mock_test_id,total_questions) values(v_user,v_test.id,v_test.question_count) returning * into v_attempt;
  select coalesce(jsonb_agg(jsonb_build_object('id',q.id,'question_text',q.question_text,'option_a',q.option_a,'option_b',q.option_b,'option_c',q.option_c,'option_d',q.option_d,'question_order',mtq.question_order) order by mtq.question_order),'[]'::jsonb) into v_questions
  from public.mock_test_questions mtq join public.questions q on q.id=mtq.question_id where mtq.mock_test_id=v_test.id;
  return jsonb_build_object('attempt_id',v_attempt.id,'started_at',v_attempt.started_at,'test',jsonb_build_object('id',v_test.id,'name',v_test.name,'description',v_test.description,'question_count',v_test.question_count,'duration_minutes',v_test.duration_minutes,'passing_percentage',v_test.passing_percentage),'questions',v_questions);
end; $$;

create or replace function public.submit_mock_test(p_attempt_id uuid,p_answers jsonb,p_time_used_seconds integer default 0)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid(); v_attempt public.exam_attempts; v_item jsonb; v_question uuid; v_selected public.answer_option; v_correct integer:=0; v_answered integer:=0; v_total integer; v_percentage numeric(5,2);
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  select * into v_attempt from public.exam_attempts where id=p_attempt_id and student_id=v_user and status='in_progress' for update;
  if not found then raise exception 'Active attempt not found'; end if;
  perform set_config('app.secure_scoring','true',true);
  for v_item in select * from jsonb_array_elements(coalesce(p_answers,'[]'::jsonb)) loop
    v_question:=(v_item->>'question_id')::uuid; v_selected:=(v_item->>'selected_answer')::public.answer_option;
    if exists(select 1 from public.mock_test_questions where mock_test_id=v_attempt.mock_test_id and question_id=v_question) then
      insert into public.attempt_answers(attempt_id,question_id,selected_answer,is_correct) select v_attempt.id,q.id,v_selected,(q.correct_answer=v_selected) from public.questions q where q.id=v_question
      on conflict(attempt_id,question_id) do update set selected_answer=excluded.selected_answer,is_correct=excluded.is_correct,answered_at=now();
    end if;
  end loop;
  select count(*),count(*) filter(where aa.is_correct) into v_answered,v_correct from public.attempt_answers aa where aa.attempt_id=v_attempt.id;
  v_total:=v_attempt.total_questions; v_percentage:=case when v_total>0 then round((v_correct::numeric/v_total::numeric)*100,2) else 0 end;
  update public.exam_attempts set status='submitted',submitted_at=now(),correct_answers=v_correct,incorrect_answers=v_answered-v_correct,unanswered=v_total-v_answered,score=v_correct,percentage=v_percentage,time_used_seconds=greatest(0,p_time_used_seconds) where id=v_attempt.id;
  return jsonb_build_object('attempt_id',v_attempt.id,'total_questions',v_total,'correct_answers',v_correct,'incorrect_answers',v_answered-v_correct,'unanswered',v_total-v_answered,'score',v_correct,'percentage',v_percentage,'passed',v_percentage>=(select passing_percentage from public.mock_tests where id=v_attempt.mock_test_id));
end; $$;

create or replace function public.protect_exam_attempt_results()
returns trigger language plpgsql security definer set search_path='' as $$
declare caller_is_admin boolean:=public.is_admin(); expected_questions integer;
begin
  if caller_is_admin or current_setting('app.secure_scoring',true)='true' then return new; end if;
  if tg_op='INSERT' then select question_count into expected_questions from public.mock_tests where id=new.mock_test_id and status='published'; if expected_questions is null then raise exception 'Test is not available'; end if; new.student_id:=auth.uid();new.status:='in_progress';new.started_at:=now();new.submitted_at:=null;new.total_questions:=expected_questions;new.correct_answers:=0;new.incorrect_answers:=0;new.unanswered:=expected_questions;new.score:=0;new.percentage:=0;new.time_used_seconds:=0;return new; end if;
  if old.status<>'in_progress' then raise exception 'Submitted or abandoned attempts are immutable'; end if;
  if new.status not in('in_progress','abandoned') then raise exception 'Attempts must be submitted through secure scoring'; end if;
  new.student_id:=old.student_id;new.mock_test_id:=old.mock_test_id;new.started_at:=old.started_at;new.submitted_at:=old.submitted_at;new.total_questions:=old.total_questions;new.correct_answers:=old.correct_answers;new.incorrect_answers:=old.incorrect_answers;new.unanswered:=old.unanswered;new.score:=old.score;new.percentage:=old.percentage;new.time_used_seconds:=old.time_used_seconds;new.created_at:=old.created_at;return new;
end; $$;

create or replace function public.protect_attempt_answer_results()
returns trigger language plpgsql security definer set search_path='' as $$
begin if public.is_admin() or current_setting('app.secure_scoring',true)='true' then return new; end if; if not exists(select 1 from public.exam_attempts a where a.id=new.attempt_id and a.student_id=auth.uid() and a.status='in_progress') then raise exception 'Answers can only be changed on your active attempt'; end if;new.is_correct:=null;new.answered_at:=now();return new;end; $$;

revoke all on function public.start_mock_test(uuid) from public;
revoke all on function public.submit_mock_test(uuid,jsonb,integer) from public;
grant execute on function public.start_mock_test(uuid) to authenticated;
grant execute on function public.submit_mock_test(uuid,jsonb,integer) to authenticated;
