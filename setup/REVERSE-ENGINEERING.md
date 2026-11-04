# Reverse engineering — existing projects

Goal: understand the codebase well enough to fill `ai/module_map.md`, `ai/conventions.md`,
`docs/Architecture.md` and `specs/_inventory.md` **without reading everything**. The output is
facts and clearly marked guesses, confirmed with the user before they become rules.

Read-only. No code changes, no refactors, no fixes — defects found along the way are noted in the
inventory.

## Token budget

- Start with structure (tree to depth 3, ignoring `node_modules`, `vendor`, `dist`, `build`,
  `.git`, caches), manifests, config and CI files. They answer most questions.
- Read entry points and one representative module per layer in full; sample the rest.
- For large repositories (hundreds of source files or several apps), delegate exploration to
  read-only subagents — one per app or layer — with a precise brief ("list routes with their
  handler files and auth guard; do not paste code") and keep only their summaries.
- Never paste file contents into the conversation; write findings directly into the drafts.

## What to establish

1. **Apps and runtime shape** — each deployable/app, its path, stack, entry point, how it is run,
   and how apps call each other (HTTP, queue, direct import). Hard boundaries that the code
   already respects (or violates).
2. **Architecture and layering** — folder conventions per app (controllers/services/
   repositories, domain/application/infra, feature folders), dependency direction, DI/wiring,
   where business rules actually live, shared modules.
3. **Data** — database(s), ORM, schema location, migration tool, naming convention of physical
   identifiers, transactions usage.
4. **Integrations** — external providers and SDKs, HTTP clients, webhooks, queues; whether they
   sit behind an interface.
5. **Auth and session** — mechanism (cookies, JWT, OAuth), where authorization is enforced,
   roles/ownership model.
6. **Cross-cutting conventions** — naming/casing, error shape, validation, config/env loading,
   logging, i18n, API docs, feature flags. Where secrets live, and whether any secret, `.env`
   file, key or dump is already tracked by git — list each one under "Open points" as a risk
   (compromised until rotated); never delete or rewrite anything.
7. **Quality tooling** — test frameworks, test locations, coverage of business rules, lint,
   formatter, type checking, CI pipeline, exact commands (from manifests/CI, not guessed).
8. **Features** — the capabilities the system exposes, from routes, screens, commands, jobs and
   events. Group them by domain area.

## Outputs

Write the drafts in the target; the setup then confirms and finishes them.

- **`docs/Architecture.md`** (project language): overview of items 1–7, with "Observed" facts and
  an "Open points" list (inconsistencies, guesses, risks). Keep it under ~150 lines.
- **`ai/module_map.md`** (English): fill the template sections from items 1–2 — apps table,
  style, module layout, where each thing belongs, project-specific leakage checks. Where the code
  is inconsistent, describe the dominant pattern and note the exceptions under "Open points" in
  `docs/Architecture.md`.
- **`ai/conventions.md`** (English): fill from items 3–7; tag each convention `(observed)`. Exact
  commands in the table.
- **`specs/_inventory.md`** (project language): one table — feature/capability, domain area, entry
  points (paths), tests present (yes/partial/no), spec status (`none`), notes (observed defects,
  unclear behavior). This is the backlog for `/<prefix>.reverse`; the setup does **not** write
  feature specs.

## Confirm before finalizing

Collect the guesses and inconsistencies into at most two `AskUserQuestion` rounds (four questions
each): architecture style when mixed, dependency direction when unclear, which convention wins
when two coexist, which features are deprecated, and anything that changes a non-negotiable rule.
Unanswered items stay as "Open points" — never silently promoted to rules.
