# Concurrent exam readiness

The database path is designed for 100 concurrent student sessions, but production readiness must be proven against the deployed environment—not inferred from a local build.

## Implemented safeguards

- One active attempt per student and test, enforced by a partial unique index.
- Repeated Start requests resume the same active attempt.
- Submission locks the attempt row and is idempotent; a repeated submission returns the stored result.
- Scoring runs inside PostgreSQL and never sends answer keys to clients.
- Test questions use indexed ordered joins; questions are not duplicated per attempt.
- Supabase client is a singleton, and frontend Start/Submit controls suppress repeated calls.
- Catalog views use paginated field projections.

## Pre-launch test

Run staged tests against a non-production Supabase project with 10, 25, 50, then 100 virtual students. Each student should authenticate, start a test, retrieve 100 questions, submit answers, and read the result. Measure p50/p95/p99 latency, HTTP/database errors, database CPU, connection-pool saturation and duplicate-attempt count.

Suggested acceptance targets for the first release:

- No duplicate active attempts.
- No lost or partially scored submissions.
- Less than 1% request failures, excluding intentional rate limits.
- p95 start and submit latency under 2 seconds under the intended plan/region.
- Database CPU and connection-pool utilization remain below sustained saturation.

Tune Supabase plan limits, pooling and rate limits from observed results before announcing capacity. Never run a 100-user load test against production student data.
