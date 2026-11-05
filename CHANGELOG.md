# Changelog

All notable changes to the SDD template. Projects record the template commit they were rendered
from in `.sdd/config` (`SDD_TEMPLATE_REF` / `SDD_TEMPLATE_VERSION`).

## Unreleased

## v0.3.0 — 2026-11-04

- `commit` can now push. After the commits and the report, a new step asks (`AskUserQuestion`)
  whether to push each repository with new commits, listing branch, upstream and outgoing
  commits and flagging the default/protected branch. Outgoing commits not created by the run go
  through the leak scan first. Plain `git push` (`-u` when there is no upstream) in commit order;
  never force-push, never pull or rebase to get past a rejection, never `--no-verify`. The gate
  "Never push" becomes "push only after the user confirms it".

## v0.2.1 — 2026-11-04

- `bin/sdd`: `update`, `status` and `diff` without `--template` died with "update needs a git
  checkout of the template: cloning …" — the "cloning" notice went to stdout and was captured as
  the clone path. It now goes to stderr. The smoke test covers the clone path (local
  `SDD_TEMPLATE_REPO`, no `--template`) for the three commands.

## v0.2.0 — 2026-11-04

- Leak prevention. `commit` gains a mandatory **leak scan** on the staged changes of every
  repository — forbidden files (`.env*`, key material, credential stores, infrastructure state,
  dumps, exports, HAR/log files), secret literals (provider keys, private keys, JWTs,
  `user:password@` URLs, suspicious assignments), real personal data, weakened security controls
  and bypasses, supply-chain and infrastructure red flags — with STOP semantics (unstage and
  report; a secret that reached any commit is compromised and must be rotated), a ban on
  `--no-verify`, and a `<!-- sdd:project -->` block for project patterns. `security` checklist
  gains a "Repository hygiene & data exfiltration" group, the compromised-secret rule (Critical,
  rotate) and registry/typosquat/install-hook checks on new dependencies; its scope now includes
  the non-code files of the diff. `code` non-negotiable rules cover synthetic test data, never
  weakening a security control and dependency provenance. `express`/`fix` summaries updated;
  `start`, `reverse` and `screen` use synthetic examples only, and `reverse` reports secrets found
  in code or history.
- Scaffold and setup (apply by hand in projects — `.sdd/last-scaffold.diff`): `CLAUDE.md` gains
  two non-negotiable rules (never commit secrets or real data — commit through `/<prefix>.commit`;
  never weaken a security control) and a commit step in the mandatory workflow;
  `ai/conventions.md` gains "Secrets and sensitive files" (secret store, `.gitignore` baseline,
  synthetic data, rotation); `ai/docs-authoring-rules.md` lists the `commit` gate among the gates
  that must never be weakened; `setup/SETUP.md` asks where secrets live, fills the `commit`
  project block, checks `.gitignore` and already-tracked forbidden files; reverse engineering
  flags committed secrets as risks.
- Smoke test checks that every quality-gate heading is present in the rendered skills.
- `security` skill no longer links to the optional `security-audit` skill (dead link when it is
  not installed); the smoke test now also renders the default skill set and checks its links.
- Skills: `<!-- sdd:project -->` blocks added to `express` and `fix` (the project's critical
  areas, never handled in the fast lanes), `ask` (extra reference docs) and `tasks` (task
  conventions). `fix` gate now states that changing a critical rule is out of its scope.
- Public-repo hygiene: no references to the originating project; MIT license of the vendored
  `security-audit` skill shipped alongside it (`LICENSE` in its folder, copied into projects);
  README section on what SDD is and why it pays off; security note on `sdd update` replacing
  `.sdd/sdd`.
- Repo tooling: `CLAUDE.md` with the template editing rules, `scripts/smoke-test.sh`
  (end-to-end render/customize/update/conflict/link checks) and the `/sdd.release` skill.
  Nothing under `template/` or `bin/` changed.

## v0.1.0 — 2026-11-04

First release.

- Skills: `start`, `tasks`, `code`, `review`, `security`, `go`, `express`, `fix`, `ask`,
  `reverse`, `commit`, `update`; optional `screen` and vendored `security-audit` (Cloudflare).
- Agents: `techlead` (managed) and a per-app `_dev.template.md` (instantiated at setup).
- Project scaffold: `CLAUDE.md`, `ai/module_map.md`, `ai/conventions.md`,
  `ai/docs-authoring-rules.md`, `specs/_template/*`, `docs/Product.md`.
- `bin/sdd`: `init`, `update` (3-way merge), `status`, `diff`.
- Setup protocol with interview and reverse engineering for existing projects.
