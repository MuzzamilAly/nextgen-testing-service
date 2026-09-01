# NEXTGEN TESTING SERVICE

Production-oriented foundation for a medical and healthcare examination platform, founded by **Bharat Kolhi**.

## Stack

React, TypeScript, Tailwind CSS, shadcn/ui patterns, Supabase Auth, PostgreSQL and Row Level Security.

## Local setup

1. Install dependencies: `npm install`
2. Copy `.env.example` to `.env.local` and add your Supabase project URL and anon key.
3. Apply `supabase/migrations/202608300001_foundation.sql` in Supabase.
4. Start: `npm run dev`

The landing page renders without Supabase credentials. Authenticated features should use the exported typed client in `src/lib/supabase.ts` and explicitly handle the unconfigured state.

## Architecture

- `src/components/ui` — reusable design-system primitives
- `src/components` — shared product components
- `src/lib` — clients and utilities
- `src/types` — backend contracts
- `supabase/migrations` — versioned database schema and RLS
- `docs/database-architecture.md` — relationships, ownership and security boundaries
- `docs/security-model.md` — RLS roles and exam-result trust boundaries
- `docs/scalability-architecture.md` — catalog, assessment and future-module rules
- `docs/load-testing.md` — concurrency safeguards and production acceptance checks

## Security baseline

The browser only receives the Supabase anon key. Never expose a service-role key in `VITE_*` variables. RLS is enabled on every public table. New users receive a student profile automatically, and clients cannot promote their own role.

## Recommended next increments

Add features as vertical slices: authentication, program catalog, question bank, exam attempts, analytics, then admin authoring. Generate updated TypeScript database types after each schema change.
