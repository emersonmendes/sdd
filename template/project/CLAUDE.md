# CLAUDE.md

## Project

**{{PROJECT_NAME}}** — (setup: one line — what it is, for whom, the main actors/roles. Product
context: [`docs/Product.md`](docs/Product.md).)

(setup: the apps/repositories, one line each — name, path, stack, role — and how they talk to
each other, including hard boundaries such as "the UI never calls the API directly". Delete this
paragraph.)

## Language

- Conversation, reports, commit messages, `/specs/**` and `/docs/**`: **{{LANGUAGE}}**.
- `CLAUDE.md`, `/ai/**`, `.claude/**`, code identifiers and code comments: **English**.

## Source of Truth

**`/specs` is the single source of truth for system behavior.** Do not implement, modify, or
review behavior without first reading the relevant spec.

> Spec structure: `/specs/<feature>/spec.md` (objective, requirements, acceptance criteria, edge
> cases) · `rules.md` (authoritative business rules, numbered `R-n`) · `flows.md` (end-to-end
> flows) · `tasks.md` (implementation checklist). New specs follow `/specs/_template/`. Existing
> features without a spec are listed in `/specs/_inventory.md` and get one through
> `/{{PREFIX}}.reverse` before they are changed.

Architecture reference: [`/ai/module_map.md`](ai/module_map.md) — where each type of code belongs
(consult before touching any module). Cross-cutting mechanics and commands:
[`/ai/conventions.md`](ai/conventions.md).

## Mandatory Workflow

Before any code change:

1. Read `spec.md`, `rules.md`, and `flows.md` for the relevant feature under `/specs`.
2. Validate acceptance criteria — if anything is ambiguous, ask; never infer a requirement.
3. Update `tasks.md` if missing or outdated.
4. Read `/ai/module_map.md` and map each task to the correct app/module.
5. Implement only in the owning module/app.
6. Write tests in the owning module/app.
7. Verify every acceptance criterion is covered.
8. Check that spec and implementation do not diverge.
9. Run the security analysis (`/{{PREFIX}}.security`) — no open Critical/High finding before
   finishing.
10. Commit through `/{{PREFIX}}.commit` — nothing reaches the repository without its leak scan.

Lanes: `/{{PREFIX}}.go` (full workflow with check-points) · `/{{PREFIX}}.express` (simple
features, no questions) · `/{{PREFIX}}.fix` (small change to a specified feature) ·
`/{{PREFIX}}.reverse` (spec an existing feature). Skills live in `.claude/skills/{{PREFIX}}.*`.

## Non-Negotiable Rules

- Never implement a feature without a spec.
- Never write business logic outside `/specs`.
- Never choose a module without consulting `/ai/module_map.md`.
- Never hand-edit generated code.
- Keep business/domain code free of framework and persistence imports where
  `/ai/module_map.md` requires it.
- Writes that must succeed or fail together (as the spec states) run in one transaction.
- Lint clean and tests green before a change is done — commands in
  [`/ai/conventions.md#commands`](ai/conventions.md#commands).
- Never commit secrets, credentials, `.env*` files, dumps or real personal data; commit through
  `/{{PREFIX}}.commit`, whose leak scan must pass
  ([`/ai/conventions.md#secrets-and-sensitive-files`](ai/conventions.md#secrets-and-sensitive-files)).
- Never weaken a security control (TLS verification, auth/CSRF/CORS guards, debug modes) to make
  something work; if a task needs it, the spec is wrong — ask.
- If spec and code diverge, fix the spec first.
- When editing docs or skills, follow [`/ai/docs-authoring-rules.md`](ai/docs-authoring-rules.md)
  — one fact one home, no duplication, keep always-loaded files lean without dropping rules.
(setup: add the rules chosen in the interview, one line each, linking to the mechanics in
`ai/conventions.md` — e.g. i18n / no hardcoded user-facing strings, API docs on every endpoint,
DB naming, data protection, URL identifiers in English, confirmation dialogs, design-first UI.
Delete this paragraph.)

## Stack & Style

(setup: runtime and versions, languages, frameworks, ORM/migrations, test stacks per app, package
manager — one line each, at most ~12 lines; details go to `ai/conventions.md`. Keep these two
lines:)
- Thin entry points (controllers, handlers, UI): validation, auth, mapping, delegation. Business
  logic in application/domain code; persistence in adapters/repositories.
- Tests focus on critical paths: business rules and use cases have unit tests with fakes for
  ports (fast, no network); integration/e2e cover the main flows.

## Module Boundaries

Quick shape: (setup: e.g. `web (UI) → bff (session/aggregation) → backend (business logic)`).
**Full boundary table and the "Logic leakage check" (run it before finalizing any change) live in
[`/ai/module_map.md`](ai/module_map.md)** — consult before touching any module.
