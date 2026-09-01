-- Subscription entitlements. Payment processing remains a separate future integration.
create type public.subscription_status as enum('active','expired','cancelled');
create table public.subscriptions(
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_name text not null default 'Student Access' check(char_length(plan_name) between 2 and 80),
  status public.subscription_status not null default 'active',
  starts_at timestamptz not null default now(),
  ends_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check(ends_at>starts_at)
);
create unique index one_active_subscription_per_user on public.subscriptions(user_id) where status='active';
create index subscriptions_access_lookup on public.subscriptions(user_id,status,ends_at);
create trigger subscriptions_set_updated_at before update on public.subscriptions for each row execute function public.set_updated_at();
alter table public.subscriptions enable row level security;
create policy "Students view own subscription" on public.subscriptions for select to authenticated using(user_id=(select auth.uid()) or (select public.is_admin()));
create policy "Admins manage subscriptions" on public.subscriptions for all to authenticated using((select public.is_admin())) with check((select public.is_admin()));

create or replace function public.has_active_subscription(p_user_id uuid default auth.uid())
returns boolean language sql stable security definer set search_path='' as $$
  select exists(select 1 from public.subscriptions s where s.user_id=p_user_id and s.status='active' and s.starts_at<=now() and s.ends_at>now());
$$;
revoke all on function public.has_active_subscription(uuid) from public;
grant execute on function public.has_active_subscription(uuid) to authenticated;

create or replace function public.admin_grant_subscription(p_email text,p_days integer default 30,p_plan_name text default 'Student Access')
returns uuid language plpgsql security definer set search_path='' as $$
declare v_user uuid;v_id uuid;
begin
  if not public.is_admin() then raise exception 'Admin access required';end if;
  if p_days<1 or p_days>730 then raise exception 'Subscription duration must be between 1 and 730 days';end if;
  select id into v_user from public.profiles where lower(email)=lower(trim(p_email));
  if v_user is null then raise exception 'Student email not found';end if;
  update public.subscriptions set status='expired' where user_id=v_user and status='active';
  insert into public.subscriptions(user_id,plan_name,status,starts_at,ends_at) values(v_user,p_plan_name,'active',now(),now()+make_interval(days=>p_days)) returning id into v_id;
  return v_id;
end;$$;
revoke all on function public.admin_grant_subscription(text,integer,text) from public;
grant execute on function public.admin_grant_subscription(text,integer,text) to authenticated;

create or replace function public.start_mock_test(p_mock_test_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_user uuid:=auth.uid();v_attempt public.exam_attempts;v_test public.mock_tests;v_questions jsonb;v_total integer;
begin
  if v_user is null then raise exception 'Authentication required';end if;
  if not public.is_admin() and not public.has_active_subscription(v_user) then raise exception 'SUBSCRIPTION_REQUIRED: Please activate a subscription before starting a test';end if;
  select * into v_test from public.mock_tests where id=p_mock_test_id and status='published';if not found then raise exception 'Test is not available';end if;
  select count(*) into v_total from public.mock_test_questions where mock_test_id=v_test.id;if v_total=0 then raise exception 'Test has no questions';end if;
  insert into public.exam_attempts(student_id,mock_test_id,total_questions) values(v_user,v_test.id,v_total) on conflict(student_id,mock_test_id) where status='in_progress' do update set student_id=excluded.student_id returning * into v_attempt;
  select coalesce(jsonb_agg(jsonb_build_object('id',q.id,'question_text',q.question_text,'option_a',q.option_a,'option_b',q.option_b,'option_c',q.option_c,'option_d',q.option_d,'question_order',mtq.question_order) order by mtq.question_order),'[]'::jsonb) into v_questions from public.mock_test_questions mtq join public.questions q on q.id=mtq.question_id where mtq.mock_test_id=v_test.id;
  return jsonb_build_object('attempt_id',v_attempt.id,'started_at',v_attempt.started_at,'test',jsonb_build_object('id',v_test.id,'name',v_test.name,'description',v_test.description,'question_count',v_total,'duration_minutes',v_test.duration_minutes,'passing_percentage',v_test.passing_percentage),'questions',v_questions);
end;$$;
revoke all on function public.start_mock_test(uuid) from public;
grant execute on function public.start_mock_test(uuid) to authenticated;
