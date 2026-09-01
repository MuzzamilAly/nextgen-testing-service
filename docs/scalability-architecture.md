# Scalability and extensibility rules

## Data ownership

Universities, programs, subjects, chapters, topics, study materials, questions, blueprints and tests are PostgreSQL records. React may contain presentation copy, icon mappings and empty-state text, but never academic catalog records or answer keys.

All public catalog access goes through `src/data/catalog-repository.ts`. Repository functions paginate at the database boundary and request only fields needed by the view.

## Assessment scale

- Question bank queries must always be filtered and paginated; never fetch the complete bank.
- Mock tests reference questions through `mock_test_questions`, so 100-question tests do not duplicate question content.
- `exam_blueprints` and ordered sections define reusable university/program-specific test composition.
- `assessment_type` supports full mock tests and shorter practice quizzes on the same secure engine.
- Correct answers remain server-only. Test delivery and grading should use dedicated RPCs with versioned attempt snapshots.
- Existing composite indexes cover subject/chapter/topic filtering and ordered test assembly.

## Future bounded modules

Add future capabilities as separate migrations and service boundaries:

- `analytics`: event/aggregate tables and scheduled rollups; do not scan answers in dashboard requests.
- `ai`: tutor conversations, explanation jobs and study-plan versions. Store provider credentials only in server functions.
- `billing`: plans, subscriptions and payment events. Verify signed provider webhooks server-side and use idempotency keys.
- `notifications`: templates, preferences and delivery jobs with retry state.
- `certificates`: immutable issuance records and public verification tokens.

These modules should reference `profiles`, programs and attempts by UUID rather than copy user or academic data.

## Operational rules

- Use cursor/range pagination, selective projections and indexed filters.
- Add migrations instead of editing production tables manually.
- Generate Supabase TypeScript types after every schema migration.
- Keep the anon key in the browser; service credentials stay in trusted server runtimes.
- Use storage buckets for media and store only object paths/metadata in PostgreSQL.
