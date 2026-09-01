-- Phase 4: RLS hardening and protection of server-owned exam results.

-- Profiles: authenticated users may update only safe personal fields.
revoke update on public.profiles from authenticated;
grant update (full_name, phone, profile_photo, target_university_id, target_program_id)
  on public.profiles to authenticated;

-- An attempt's score fields are always owned by trusted database code.
create or replace function public.protect_exam_attempt_results()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  caller_is_admin boolean := public.is_admin();
  expected_questions integer;
begin
  if caller_is_admin then return new; end if;

  if tg_op = 'INSERT' then
    select question_count into expected_questions
    from public.mock_tests where id = new.mock_test_id and status = 'published';
    if expected_questions is null then raise exception 'Test is not available'; end if;
    new.student_id := auth.uid();
    new.status := 'in_progress';
    new.started_at := now();
    new.submitted_at := null;
    new.total_questions := expected_questions;
    new.correct_answers := 0; new.incorrect_answers := 0; new.unanswered := expected_questions;
    new.score := 0; new.percentage := 0; new.time_used_seconds := 0;
    return new;
  end if;

  if old.status <> 'in_progress' then
    raise exception 'Submitted or abandoned attempts are immutable';
  end if;
  if new.status not in ('in_progress', 'abandoned') then
    raise exception 'Attempts must be submitted through the secure scoring function';
  end if;
  new.student_id := old.student_id; new.mock_test_id := old.mock_test_id;
  new.started_at := old.started_at; new.submitted_at := old.submitted_at;
  new.total_questions := old.total_questions; new.correct_answers := old.correct_answers;
  new.incorrect_answers := old.incorrect_answers; new.unanswered := old.unanswered;
  new.score := old.score; new.percentage := old.percentage;
  new.time_used_seconds := old.time_used_seconds; new.created_at := old.created_at;
  return new;
end; $$;

create trigger protect_exam_attempt_results
before insert or update on public.exam_attempts
for each row execute function public.protect_exam_attempt_results();

-- Students choose an option; correctness is evaluated only by trusted code.
create or replace function public.protect_attempt_answer_results()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if public.is_admin() then return new; end if;
  if not exists (
    select 1 from public.exam_attempts a
    where a.id = new.attempt_id and a.student_id = auth.uid() and a.status = 'in_progress'
  ) then raise exception 'Answers can only be changed on your active attempt'; end if;
  new.is_correct := null;
  new.answered_at := now();
  return new;
end; $$;

create trigger protect_attempt_answer_results
before insert or update on public.attempt_answers
for each row execute function public.protect_attempt_answer_results();

-- Tighten attempt creation/update policies.
drop policy if exists "Students create own attempts" on public.exam_attempts;
drop policy if exists "Students update active own attempts" on public.exam_attempts;
create policy "Students create own attempts" on public.exam_attempts
for insert to authenticated with check (
  student_id = (select auth.uid()) and
  exists (select 1 from public.mock_tests t where t.id = mock_test_id and t.status = 'published')
);
create policy "Students may only abandon active own attempts" on public.exam_attempts
for update to authenticated using (
  student_id = (select auth.uid()) and status = 'in_progress'
) with check (
  student_id = (select auth.uid()) and status in ('in_progress', 'abandoned')
);

-- Explicit admin coverage for every authoring domain.
drop policy if exists "Admins manage programs" on public.programs;
drop policy if exists "Admins manage subjects" on public.subjects;
create policy "Admins manage programs" on public.programs for all to authenticated
  using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "Admins manage subjects" on public.subjects for all to authenticated
  using ((select public.is_admin())) with check ((select public.is_admin()));

-- Admins may inspect all student performance records without mutating history.
create policy "Admins view all attempt answers" on public.attempt_answers for select to authenticated
  using ((select public.is_admin()));

-- No client role receives direct table write access to aggregate progress.
revoke insert, update, delete on public.student_progress from anon, authenticated;

-- The service role is intentionally absent from application code. Supabase's
-- server-side service role continues to bypass RLS for trusted backend jobs.
