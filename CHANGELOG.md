# Changelog

All notable changes to the SDD template. Projects record the template commit they were rendered
from in `.sdd/config` (`SDD_TEMPLATE_REF` / `SDD_TEMPLATE_VERSION`).

## Unreleased

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
