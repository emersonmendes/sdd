# Setup protocol — adopt SDD in a project

Instructions for the assistant that runs the setup (Claude Code, in the target project's root).
Follow the phases in order. Ask with `AskUserQuestion` when available; otherwise ask in chat and
wait. Do not commit anything.

Terms: **template clone** = the local checkout of this repository; **target** = the project being
set up (the current working directory).

## Phase 0 — Preflight

1. If no template clone was given, clone it: `git clone https://github.com/emersonmendes/sdd.git <tmp>/sdd`
   (use a scratch/temporary directory, never inside the target).
2. Confirm the target is a git repository root. If `.sdd/config` already exists, **STOP**: the
   project is already set up — use `/<prefix>.update` instead.
3. Detect, without reading whole files (list names, read manifests only):
   - package/build manifests (`package.json`, `pnpm-workspace.yaml`, `pyproject.toml`, `go.mod`,
     `pom.xml`, `build.gradle`, `Cargo.toml`, `Gemfile`, `composer.json`, `*.csproj`, `*.sln`);
   - monorepo markers (`apps/`, `packages/`, workspaces), docker/compose files, CI config;
   - existing `CLAUDE.md`, `.claude/skills`, `.claude/agents`, `specs/`, `docs/`, `ai/`;
   - whether there is source code at all (new vs existing project);
   - README title and first paragraph.
4. Show a one-screen detection summary (apps found, stacks guessed, test/lint scripts found).
   Everything detected becomes a **default** in the interview, not a question.

## Phase 1 — Interview

Ask in at most three rounds, four questions per round. Skip anything already detected or stated
by the user; put defaults first and mark them "(Recommended)". From round 1 on, talk to the user
in the chosen language.

**Round 1 — identity**
1. Language for conversation, reports, commits, specs and docs (skills, `CLAUDE.md` and `ai/`
   stay in English). Free text or options such as English / Português (Brasil) / Español.
2. Project name (human) — default: the README title or the folder name.
3. Skill prefix (lowercase kebab-case, used as `/<prefix>.start`) — default: the folder name.
4. New project (no code yet) or existing project — default from detection.

**Round 2 — architecture and technologies** (for an existing project, run
[Phase 2](#phase-2--reverse-engineering-existing-projects-only) **first**, then ask this round
only to confirm the findings)
1. Apps/repositories: name, path, role (API, UI, BFF, mobile shell, worker, CLI, library),
   stack. One line each; ask as free text when detection is empty.
2. Architecture style: pragmatic hexagonal (ports & adapters where it hurts) (Recommended) /
   clean architecture / layered MVC / feature folders / other. And the dependency direction.
3. Data and integrations: database + ORM/migration tool; message broker; external providers
   (payment, email, storage, auth); where secrets live (environment files, platform secret
   manager, vault); how apps communicate and any hard boundary ("UI never calls the API
   directly").
4. Commands per app: install, test, lint, format, dependency audit, run — plus runtime versions
   and package manager.

**Round 3 — rules and options**
1. Non-negotiable rules to adopt (multi-select; propose only those that fit the stack):
   business code free of framework/persistence imports; API docs on every endpoint; i18n / no
   hardcoded user-facing strings; DB naming convention; transactions for all-or-nothing writes;
   data-protection classification (LGPD/GDPR); URL/identifiers in English; no native
   confirm/alert dialogs; design-first UI (screen designs before implementation); never edit
   generated code; lint clean before done.
2. Optional skills: `screen` (Claude Design prompts; needs `docs/Screens/`), `security-audit`
   (vendored Cloudflare deep audit; ~6k lines, opt-in runs only). `commit` is on by default —
   ask the commit convention (Conventional Commits (Recommended) / `scope: subject` / custom)
   and the message language.
3. Specialist agents: generate one `<app>-dev` agent per app for parallel delegation —
   recommended when there are two or more apps; skip for a single app.
4. Models: implement = `sonnet`, lead = `opus` (defaults; change only if the user asks).

Record every answer; they become `.sdd/config` values and the content of the scaffold files.

## Phase 2 — Reverse engineering (existing projects only)

Follow [`REVERSE-ENGINEERING.md`](REVERSE-ENGINEERING.md). It produces `docs/Architecture.md`,
the filled `ai/module_map.md` and `ai/conventions.md` drafts, and `specs/_inventory.md`. Confirm
the uncertain findings with the user (that is round 2 of the interview), then continue.

## Phase 3 — Write the config and render

1. Write `.sdd/config` in the target:

   ```
   # sdd project config — read by .sdd/sdd and by /<prefix>.update
   SDD_TEMPLATE_REPO=https://github.com/emersonmendes/sdd.git
   SDD_PREFIX=<prefix>
   SDD_PROJECT_NAME="<Project Name>"
   SDD_LANGUAGE=<language, e.g. English | Português (Brasil)>
   SDD_MODEL_IMPLEMENT=sonnet
   SDD_MODEL_LEAD=opus
   SDD_SKILLS="start tasks code review security go express fix ask reverse commit update"
   ```

   Append `screen` and/or `security-audit` to `SDD_SKILLS` when chosen. `SDD_TEMPLATE_REF` and
   `SDD_TEMPLATE_VERSION` are written by the script.
2. Run `bash <template clone>/bin/sdd init --template <template clone>` from the target root. It
   renders the skills into `.claude/skills/<prefix>.*`, the `techlead` agent, installs
   `.sdd/sdd`, and copies the scaffold files (`CLAUDE.md`, `ai/*`, `specs/_template/*`,
   `docs/Product.md`) **only where they do not exist**.
3. If the target already had a `CLAUDE.md`, merge: keep the project's content, add the
   template's sections (Source of Truth, Mandatory Workflow, Non-Negotiable Rules, Language),
   and move long explanations into `ai/*.md` per `ai/docs-authoring-rules.md`.

## Phase 4 — Adapt to the project

Work through every file that contains `(setup:` and every `<!-- sdd:project -->` block:

1. **`CLAUDE.md`** — project line, apps/boundaries, non-negotiable rules chosen, stack & style,
   module boundaries quick shape. Keep it lean: it loads on every turn.
2. **`ai/module_map.md`** — apps table, architecture style and rigor levels, module layout,
   dependency direction and wiring, "where each thing belongs", project-specific leakage checks.
   For existing projects, use the reverse-engineering draft.
3. **`ai/conventions.md`** — commands table (exact), testing, naming, errors, config, secrets and
   sensitive files (secret store, synthetic-data helpers, rotation contact), and only the optional
   sections that apply (API docs, database, i18n, data protection, UI references), plus the
   commit convention. Delete sections that do not apply.
4. **`docs/Product.md`** — from the interview and the README, in the project language.
5. **Skills' project blocks** — `code` (implementation notes), `review` (project checklist
   lines), `security` (stack-specific checks), `commit` (project-specific leak patterns and
   allowed exceptions), `tasks` (task conventions), `express` and `fix` (the project's critical
   areas), `ask` (extra reference docs), `screen` (shared UI patterns, if enabled). Replace the
   guidance with project facts or leave the block empty; keep the markers.
6. **Specialist agents** (if chosen) — for each app, copy
   `<template clone>/template/agents/_dev.template.md` to `.claude/agents/<app>-dev.md` and fill
   `{{APP}}`, `{{APP_ROLE}}`, `{{APP_PATH}}`, `{{APP_STACK}}`, `{{TEST_CMD}}`, `{{LINT_CMD}}`,
   `{{PREFIX}}`, `{{MODEL_IMPLEMENT}}`, the convention sections, and the provider/consumer
   contract paragraph. Give each a distinct `color`.
7. **`.gitignore` and tracked files** — make sure the baseline patterns from
   `ai/conventions.md` ("Secrets and sensitive files") are present in every repository's
   `.gitignore`; append the missing ones. Then check what is already tracked: match `git ls-files`
   against the forbidden-file list of the `commit` skill's leak scan (`.env*` except examples,
   key material, credential stores, `*.tfstate`, dumps, HAR/log files) and grep the tree for
   obvious secret literals. Report every hit to the user as a finding — do not delete files or
   rewrite history; a tracked secret is compromised and must be rotated by the team.
8. **Language** — if the chosen language is not English, translate the scaffold files that humans
   read: `specs/_template/*.md` and `docs/Product.md`. Keep `CLAUDE.md`, `ai/*.md` and `.claude/**`
   in English.
9. Delete every `(setup: …)` paragraph. Do not change template-owned text outside the project
   blocks — improvements belong in the template repository.

## Phase 5 — Verify and hand over

1. `grep -rn "(setup:" CLAUDE.md ai docs specs .claude` returns nothing;
   `grep -rln "{{[A-Z_]*}}" CLAUDE.md ai .claude` returns nothing.
2. Every relative link in `CLAUDE.md`, `ai/*.md` and the rendered skills resolves.
3. `bash .sdd/sdd status` shows the template version and no leftovers.
4. For an existing project: `specs/_inventory.md` lists the features found, none marked as
   specified yet.
5. `.gitignore` carries the baseline patterns, and the tracked-files check of Phase 4 either came
   back clean or its findings are in the report.
6. Report in the project language: files created, decisions recorded, and the next steps —
   new project: `/<prefix>.go <first feature>`; existing project: `/<prefix>.reverse <feature>`
   before any `/<prefix>.fix` on it; commit with `/<prefix>.commit` when ready. Do not commit.
