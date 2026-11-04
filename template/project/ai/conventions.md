# Cross-cutting Conventions — {{PROJECT_NAME}}

Detailed engineering conventions referenced (one line each) from `CLAUDE.md`. This file is loaded
**on demand** — read the section for the surface you are touching. The one-line imperative in
`CLAUDE.md` is authoritative; this file holds the mechanics and rationale.

(setup: fill every section below from the interview and, for existing projects, from the
reverse-engineering findings. Mark a convention `(observed)` when the codebase already follows it
and `(adopted)` when it is a new decision. Delete sections that genuinely do not apply, and delete
every "(setup: …)" paragraph.)

## Commands

Per app/repository. These are the commands the skills and agents run; keep them exact.

| App | Install | Test | Lint | Format | Dependency audit | Run locally |
|---|---|---|---|---|---|---|
| (setup) | | | | | | |

Runtime: (setup: required runtime versions and how to select them locally, e.g. Node 24 via `n`,
Python 3.12 via `uv`.)

## Testing

- Stack per app: (setup: e.g. Jest + Supertest for the API; Jest + Testing Library for the UI;
  Playwright for e2e when it makes sense.)
- Unit tests for business rules and use cases use **fakes** for ports — fast, deterministic, no
  network, no real time.
- Integration/e2e tests cover the critical paths named in the spec.
- Every test cites the rule or acceptance criterion it covers (`R-3`, `AC-2`).
- Where tests live: (setup: folder/naming convention per app.)

## Naming

- Code identifiers, files, folders, URL paths, query params, slugs, database identifiers and
  commit scopes: **English**. User-facing copy: {{LANGUAGE}} via i18n when applicable.
- (setup: casing rules per surface — files, classes, functions, DB tables/columns, env vars.)

## Errors and validation

- Validate every input at the trust boundary (type, length, format, range); never rely on a
  client or gateway as the only check.
- Errors returned to clients are generic (code + message); no stack traces, queries or internal
  paths. Internal errors are logged with context but without secrets or personal data.
- (setup: the project's error shape/codes, validation library, and where validation lives.)

## Configuration and environment variables

- Config is read from the environment, never hard-coded; every variable is documented in a
  committed `*.example` template. Real `.env*` files are git-ignored.
- Server-only secrets are never exposed to clients (setup: name the client-exposure mechanism to
  avoid, e.g. `NEXT_PUBLIC_`, `VITE_`).
- (setup: how config is loaded and validated at startup.)

## API documentation

(setup: keep if the project has an HTTP API. e.g. "Every endpoint carries OpenAPI decorators;
request/response DTOs annotated; the docs UI is exposed in development only." Otherwise delete.)

## Database

(setup: keep if the project has a database. Naming convention for physical identifiers,
migration tool and the rule "never raw SQL outside migrations", transaction expectations.
Otherwise delete.)

## i18n — user-facing strings

(setup: keep if the project has a UI. Where the dictionary lives, how components receive copy,
the rule "no hardcoded user-facing strings". Otherwise delete.)

## Data protection

(setup: keep if the project stores personal data. Which fields are high-risk, how they are
stored (encryption at rest, field-level), what may be logged, and the rule that every new
personal-data field is classified in its spec. Name the regulation: LGPD, GDPR, …. Otherwise
delete.)

## UI design references

(setup: keep if the project has a UI and uses screen designs. Where designs live
(`docs/Screens/<actor>-<screen>.html`), the design-tokens doc, and the rule to follow designs
faithfully. Otherwise delete.)

## Commit convention

- Format: (setup: e.g. Conventional Commits `type(scope): subject`, or `spec <feature>: subject`
  for spec changes and `<app>: subject` for code; choose one and show two examples.)
- Language of messages: (setup: {{LANGUAGE}} or English.)
- One commit per touched repository; subject ≤ 72 characters, imperative, says what and why.
- Never commit secrets, `.env*`, or real personal data. Never push without being asked.
