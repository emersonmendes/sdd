---
name: {{PREFIX}}.review
description: SDD step 4 (essential, do not skip). Invoked by /{{PREFIX}}.review or "review / validate implementation / check against the spec". Produces a compliance report comparing the code against /specs, plus clean-code and test-quality checks; writes no code.
metadata:
  depends_on: {{PREFIX}}.code
---

# {{PREFIX}}.review — Review (SDD step 4, ESSENTIAL)

Validation of the implementation against the spec. Do not skip. Produces no new code — only a
report.

> Project context and rules: see `CLAUDE.md` and `ai/module_map.md`. Report in {{LANGUAGE}}.

## Dependency and prerequisite (check before anything else)

Depends on `{{PREFIX}}.code` (chain: `{{PREFIX}}.start` → `{{PREFIX}}.tasks` → `{{PREFIX}}.code`
→ `{{PREFIX}}.review` → `{{PREFIX}}.security`). Confirm that:
- The spec is complete: `/specs/<feature>/spec.md`, `flows.md`, `rules.md`, `tasks.md`.
- A corresponding implementation exists (mapped in the tasks). Use `git status` / `git log` or
  search for the files referenced in `tasks.md`.

If the spec is incomplete: ask for the missing step (`/{{PREFIX}}.start` or `/{{PREFIX}}.tasks`).
If no implementation is detectable: **STOP** and ask for `/{{PREFIX}}.code` — with no code, there
is nothing to review.

## How to act

Act as a **Reviewer Agent**.

1. Identify the target feature.
2. Read the full spec: `spec.md`, `flows.md`, `rules.md`, `tasks.md`.
3. Inspect the implementation — the feature's diff (`git diff`, `git diff <base>...HEAD`, or the
   files listed in `tasks.md`) in the relevant apps/modules.
4. Inspect the corresponding tests.
5. If a bug-hunting review tool is available in the session (e.g. Claude Code's `/code-review`
   skill), run it over the same diff at medium effort and fold its confirmed findings into
   [Issues found](#2-issues-found). It complements this checklist (bugs); it never replaces it
   (spec compliance).

## Mandatory checklist

**Spec compliance**
- [ ] All acceptance criteria from the spec are covered
- [ ] There are tests for each business rule (critical domain rules and use cases first)
- [ ] No extra behavior outside the spec; no requirement silently inferred
- [ ] `tasks.md` ticked and consistent with the diff

**Architecture & boundaries**
- [ ] Correct use of apps/modules/layers (per `/ai/module_map.md`); the logic leakage check passes
- [ ] Dependency direction respected; business code does not import framework or persistence
      libraries where the map forbids it
- [ ] External integration behind a **port + adapter**; no business rule inside adapters
- [ ] Shared types/contracts carry no business rule
- [ ] Entry points thin; UI/clients do not duplicate service/domain logic
- [ ] All-or-nothing writes atomic (one transaction); webhooks idempotent when required

**Clean code**
- [ ] Names clear; functions small with one responsibility; no deep nesting
- [ ] No duplication, dead code, commented-out code, debug output, or unexplained TODOs
- [ ] Errors handled explicitly at boundaries; no silent catches
- [ ] No magic values; no speculative abstractions or unused options
- [ ] No hand-edited generated code; schema changes via the project's migration tool

**Tests**
- [ ] Tests assert spec-defined behavior and cite the rule; the spec's edge cases are covered
- [ ] Unit tests use fakes for ports (no network, no real time); no flaky patterns
- [ ] Tests fail for the right reason (not tautological, not asserting on mocks)

**Project conventions** (from the non-negotiable rules in `CLAUDE.md`)
- [ ] No hardcoded user-facing strings (when the i18n rule applies)
- [ ] Lint clean and tests green in every touched app
<!-- sdd:project -->
(setup: add project-specific checklist lines here — e.g. API docs on every endpoint, DB naming,
data-protection classification, URL identifiers in English. One line each, linking to the owning
rule. Delete this paragraph.)
<!-- /sdd:project -->

## Expected output

Produce a report with three sections:

### 1. Compliance report
Item-by-item status of the checklist above.

### 2. Issues found
List of divergences between spec and code, each with:
- Violated criterion/rule
- Location (`file:line`)
- Severity (blocking / non-blocking)

### 3. Suggested fixes
Fix suggestions for each issue. If there is a divergence where the spec is the one that is wrong,
point it out — the project rule is **fix the spec first** before the code.

At the end, suggest the next step: `/{{PREFIX}}.security`.
