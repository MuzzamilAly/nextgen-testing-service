# Database architecture

## Ownership map

```text
universities ──< programs
      │              │
      └── profiles targets

subjects ──< chapters ──< topics
    │           │           │
    ├───────────┴───────────┴──< study_materials
    ├───────────┴───────────┴──< questions
    └──────────────────────────< student_progress

mock_tests ──< mock_test_questions >── questions
    │
    └──< exam_attempts ──< attempt_answers
             │
          profiles
```

## Security boundaries

- Published catalog content is public; draft and archived content is admin-only.
- The question bank is admin-only because rows contain `correct_answer`.
- Students can create and view only their own attempts and answers.
- A student can update answers only while the owning attempt is `in_progress`.
- Aggregate progress is readable by its student and admins. Client writes are intentionally disabled.
- Admin checks use the security-definer `is_admin()` helper to avoid recursive profile RLS.

## Lifecycle rules

- Academic child records cascade when their parent catalog record is deleted.
- Questions and submitted test relationships use restrictive deletion to protect exam history.
- Student-owned attempt/progress data cascades when the corresponding auth profile is deleted.
- Profile university/program targets become `null` if catalog targets are deleted.

## Migration order

Apply every migration in `supabase/migrations` in filename order. Migration `004` evolves the Phase 1 catalog tables and must follow migrations `001`–`003`.

In the exam-engine phase, use security-definer database functions for test delivery, answer grading, attempt submission and progress aggregation. Never expose correct answers to the browser before submission.
