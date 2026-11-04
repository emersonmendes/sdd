# sdd — Spec-Driven Development template for Claude Code

[Português (Brasil)](README.pt-BR.md)

A reusable set of **Claude Code skills, agents and project docs** that puts a project on a
Spec-Driven Development (SDD) workflow: every behavior starts as a spec, code is implemented from
tasks, and nothing is done until it passes a compliance review and a security analysis.

The template is **rendered into each project** (skill names get the project's prefix, docs get the
project's facts) and can later be **updated from this repository** with a 3-way merge that keeps
the project's customizations.

## What is SDD, and why use it

**Spec-Driven Development** means every behavior is written down before it is built: a short spec
with the objective, numbered business rules, end-to-end flows and verifiable acceptance criteria.
That spec is the single source of truth. Code is derived from it through an explicit chain
(spec → tasks → code → review → security), tests cite the rules they cover, and when reality
changes, the spec changes first.

With an AI coding assistant this discipline pays off quickly:

- **Fewer wrong features.** The assistant is not allowed to infer requirements. Ambiguity is
  resolved in a two-page spec before any code exists, not discovered in a forty-file diff.
- **Reviews you can actually do.** You approve the spec, then the task list, then the code — one
  check-point per step instead of one big "looks fine".
- **Tests that mean something.** Numbered rules and acceptance criteria map one-to-one to tests;
  the review step checks that every rule has one.
- **Context that survives the session.** Specs, the module map and the conventions live in files,
  so a new session, a teammate or a different model gets the same instructions. Nothing important
  lives only in chat history.
- **Lower token cost.** Lean always-loaded files, detail on demand, a cheaper model for
  implementation and an express lane for simple features.
- **Security as a gate, not an afterthought.** Nothing is done with a Critical or High finding
  open, and nothing is committed with a secret, a credential file, real personal data or a
  disabled security control in the diff.
- **Legacy code included.** `reverse` writes the spec of what existing code does today, so old
  features get the same treatment as new ones.

Skip it for throwaway prototypes and one-off scripts. Use it for anything you will maintain.

## What you get

| Skill | Purpose |
|---|---|
| `/<prefix>.start` | Step 1 — `spec.md`, `flows.md`, `rules.md` under `/specs/<feature>/` |
| `/<prefix>.tasks` | Step 2 — `tasks.md` mapped to app/module/layer, with a contract between apps |
| `/<prefix>.code` | Step 3 — implement from `tasks.md`, with tests, clean-code baseline, green lint; delegates multi-app work to specialist agents |
| `/<prefix>.review` | Step 4 — spec compliance, architecture, clean code and test-quality report |
| `/<prefix>.security` | Step 5 — AppSec checklist (access control, injection, secrets, data exposure, repository hygiene, supply chain), OWASP-mapped findings, severity gate (no Critical/High open) |
| `/<prefix>.go` | The five steps with an approval check-point after each |
| `/<prefix>.express` | Token-lean lane for simple features: no questions, no check-points, skips review, never skips security |
| `/<prefix>.fix` | Small change to an already-specified feature, with inline self-review and security pass |
| `/<prefix>.reverse` | Spec from existing code — brings legacy features under SDD |
| `/<prefix>.ask` | Architecture/technical advisor; writes no code |
| `/<prefix>.commit` | Leak scan on the staged changes (secrets, forbidden files, real data, weakened controls, untrusted dependencies), then one clean commit per touched repository; never pushes |
| `/<prefix>.update` | Sync the project with this template |
| `/<prefix>.screen` (optional) | Prompt generator for Claude Design screens |
| `/<prefix>.security-audit` (optional) | Vendored [Cloudflare security-audit](https://github.com/cloudflare/security-audit-skill) for periodic deep audits |

Agents: `techlead` (main session, drives the skills and delegates) and one `<app>-dev` specialist
per app (generated at setup) that implements a slice and reports `BLOCKED:` instead of guessing.

Project docs: `CLAUDE.md` (lean, always loaded), `ai/module_map.md` (where code belongs, logic
leakage check), `ai/conventions.md` (commands, testing, naming, i18n, DB, env, commits),
`ai/docs-authoring-rules.md` (token hygiene), `specs/_template/*`, `docs/Product.md`.

Principles baked into the skills: specs as the single source of truth, clean code, tests for every
business rule, token economy (lean always-loaded files, on-demand detail, a cheaper model for
implementation, an express lane), mandatory review, security and leak-scan gates.

## Quick start

Requirements: Claude Code, `git`, `bash` 4+.

Open Claude Code in the project (new or existing) and paste:

```
Set up Spec-Driven Development in this project from the template at
https://github.com/emersonmendes/sdd. Clone it into a temporary folder, read its
setup/SETUP.md and follow it step by step: interview me first (start by asking which
language I want to use), reverse-engineer the codebase if this is an existing project,
then render and adapt the skills, agents and project docs. Do not commit anything.
```

The setup will:

1. Detect what the project already has (manifests, apps, scripts).
2. Interview you: language, project name and skill prefix, **architecture and technologies**
   (apps, style, data, integrations, commands), the non-negotiable rules to adopt, optional
   skills, commit convention, specialist agents.
3. For an existing project, **reverse-engineer** the codebase first
   ([`setup/REVERSE-ENGINEERING.md`](setup/REVERSE-ENGINEERING.md)): `docs/Architecture.md`,
   filled `ai/*.md` drafts, and `specs/_inventory.md` (features found, to be specified on demand
   with `/<prefix>.reverse`).
4. Write `.sdd/config`, run `bin/sdd init`, adapt the project blocks and scaffold, verify.

The chosen language applies to the conversation, reports, commits, `/specs` and `/docs`. Skills,
`CLAUDE.md` and `ai/` stay in English (fewer tokens, more reliable instructions).

## Daily workflow

```
/<prefix>.go  <feature description>        # full workflow, check-point after each step
/<prefix>.express <small feature>          # simple feature, no questions
/<prefix>.fix <small change>               # change to a specified feature
/<prefix>.reverse <existing feature>       # write the spec of what the code does today
/<prefix>.ask <question>                   # advice, no code
/<prefix>.commit                           # one commit per touched repo
```

Or run the main session as the tech lead: `claude --agent techlead`.

## Updating projects from this template

Each project records the template commit it was rendered from in `.sdd/config`. To update:

```
/<prefix>.update          # in Claude Code — runs the script, resolves conflicts, verifies
bash .sdd/sdd update      # or by hand; add --ref v0.2.0 to pin a version
bash .sdd/sdd status      # template version, latest remote, customized files
bash .sdd/sdd diff        # the project's customizations vs the pristine render
```

How the merge works: for every managed file (skills, `techlead` agent, the script itself), the
pristine render at the previous template ref is the merge base; the project's file and the new
render are the two sides. Unchanged files are replaced, customized files are merged
(`git merge-file`), real conflicts are left as markers for `/<prefix>.update` to resolve.
Scaffold files (`CLAUDE.md`, `ai/*`, `specs/_template`, `docs/Product.md`, `<app>-dev` agents)
are project-owned: the script reports their template changes in `.sdd/last-scaffold.diff` and never
overwrites them.

Customize skills inside their `<!-- sdd:project -->` blocks; generic improvements belong here —
`bash .sdd/sdd diff <file>` gives you the patch to contribute.

Security note: `sdd update` replaces `.sdd/sdd` with the template's script and rewrites the
managed skills, so point `SDD_TEMPLATE_REPO` only at a repository you trust (your own fork is a
good default) and review the diff before committing an update.

## Repository layout

```
bin/sdd                      # init | update | status | diff (bash + git, no dependencies)
scripts/smoke-test.sh        # end-to-end test of the template and the script
CLAUDE.md, .claude/skills/   # rules and the release skill for working on this repo with Claude Code
setup/SETUP.md               # the protocol the assistant follows at setup
setup/REVERSE-ENGINEERING.md # how existing projects are mapped before rendering
template/manifest            # skills and their defaults
template/skills/<name>/      # skill templates ({{PREFIX}}, {{PROJECT_NAME}}, {{LANGUAGE}}, {{MODEL_*}})
template/agents/             # techlead.md (managed) and _dev.template.md (per app, at setup)
template/project/            # scaffold: CLAUDE.md, ai/, specs/_template/, docs/Product.md
```

Placeholders rendered by the script: `{{PREFIX}}`, `{{PROJECT_NAME}}`, `{{LANGUAGE}}`,
`{{MODEL_IMPLEMENT}}`, `{{MODEL_LEAD}}`. Project-specific content lives in `<!-- sdd:project -->`
blocks and in the scaffold files.

## Developing the template

Open Claude Code in this repository: its `CLAUDE.md` holds the editing rules (generic skills,
allowed placeholders, gates that must never be weakened, link conventions) and `/sdd.release`
cuts a release. Before committing a change:

```
bash scripts/smoke-test.sh   # renders a demo project, customizes, updates to a v2, checks merge/conflict/links
```

## Versioning

Tags follow semver (`v0.1.0`); see [CHANGELOG.md](CHANGELOG.md). Projects pin the commit they
rendered; `sdd update --ref <tag>` pins a release.

## Credits and license

MIT — see [LICENSE](LICENSE). The optional `security-audit` skill is Cloudflare's
([cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill), MIT),
vendored unchanged except for its name; its license ships inside its folder
(`template/skills/security-audit/LICENSE`, see `UPSTREAM.md` there).
