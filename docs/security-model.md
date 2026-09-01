# Security model

The browser uses only `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`. A Supabase service-role key must only exist in a trusted server environment and must never use a `VITE_` prefix.

## Students

- Read their own profile and update only approved personal fields.
- Read published catalog content and available tests.
- Create attempts only for published tests; the database assigns ownership and initializes all score fields.
- Read only their own attempts, answers and progress.
- Change answers only while an attempt is active.
- Cannot supply correctness values, scores or percentages.
- Cannot update an attempt after submission or abandonment.
- Cannot read question-bank answer keys or use admin write policies.

## Admins

Admin policies cover universities, programs, subjects, chapters, topics, study materials, questions, tests and test-question membership. Admins can read profiles, attempts, answers and progress for student-performance reporting.

Admin status is stored in `profiles.role` and checked through `public.is_admin()`. A student cannot promote their own role. Assign the first admin from a trusted Supabase SQL session or server-side administrative process.

## Exam engine boundary

Direct student submission is intentionally not implemented at this layer. A later exam-engine migration should expose a security-definer RPC that atomically grades an active attempt, stores server-calculated results, marks it submitted and updates progress. This avoids sending `correct_answer` values to the browser.
