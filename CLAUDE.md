# CLAUDE.md

## Project

**sdd** — the Spec-Driven Development template for Claude Code: skills, agents, project scaffold,
setup protocol and the `bin/sdd` script that projects render from and later update with. This
repository is a **template, not a product**: it has no `/specs`, no application code, and the SDD
skills do not run here. Everything under `template/` ends up inside other projects; everything
else is tooling and documentation for this repository.

Consumers: projects rendered from this template through the README prompt.
They record the commit they rendered in `.sdd/config` and run `bash .sdd/sdd update` to pull
changes. **Assume every edit under `template/` and `bin/` reaches every consumer on their next
update.**

## Layout

| Path | What it is | Reaches projects how |
|---|---|---|
| `template/skills/<name>/` | Skill templates with placeholders | Rendered to `.claude/skills/<prefix>.<name>/`, 3-way merged on update |
| `template/agents/techlead.md` | Tech lead agent | Rendered, merged on update |
| `template/agents/_dev.template.md` | Per-app specialist agent | Instantiated by the setup; changes reported, never merged |
| `template/project/` | Scaffold: `CLAUDE.md`, `ai/`, `specs/_template/`, `docs/Product.md` | Copied once at init; changes reported in `.sdd/last-scaffold.diff` |
| `template/manifest` | Skill list and defaults | Read by the setup |
| `bin/sdd` | `init` / `update` / `status` / `diff` / `enable` / `decline` | Installed as `.sdd/sdd`, replaced on update |
| `setup/` | Setup and reverse-engineering protocols | Read by the assistant during setup |
| `scripts/smoke-test.sh` | End-to-end test of render, customize, update, conflict, status, diff | Repo only |
| `README.md`, `README.pt-BR.md`, `CHANGELOG.md` | Docs | Repo only; keep EN and PT in sync |

## Rules for editing the template

- Everything in this repository is written in **English**. Talk to the user in the language they
  use.
- Skills under `template/skills/` stay **generic**: no stack, product, company or project names.
  Project-specific content belongs in the skill's `<!-- sdd:project -->` block (as `(setup: …)`
  guidance) or in `template/project/` `(setup: …)` paragraphs that the setup fills.
- Placeholders are only `{{PREFIX}}`, `{{PROJECT_NAME}}`, `{{LANGUAGE}}`, `{{MODEL_IMPLEMENT}}`,
  `{{MODEL_LEAD}}`, substituted in `*.md` files by `render_file` in `bin/sdd`. Adding one means
  changing `render_file`, `setup/SETUP.md` (config block) and both READMEs. `_dev.template.md`
  uses extra `{{APP*}}`/`{{TEST_CMD}}`/`{{LINT_CMD}}` tokens that the setup fills by hand.
- Never weaken a quality gate: prerequisite STOPs, the `review` and `security` checklists, the
  severity gate, the `go` check-point protocol, the `express` and `fix` gates, the `code`
  non-negotiable rules and clean-code baseline, the `commit` gate and leak scan. Reword, reorder,
  extend — never drop. The smoke test checks that the gate headings are still there.
- Token hygiene rules in
  [`template/project/ai/docs-authoring-rules.md`](template/project/ai/docs-authoring-rules.md)
  apply to the skills themselves: one fact one home, lean `description`, no "When to use" or
  "Fixed context" sections, links instead of copies.
- Skill frontmatter: supported keys only (`name`, `description`, `metadata`, `model`); the
  `description` keeps its routing triggers (`/{{PREFIX}}.<name>` plus 1–2 natural-language
  synonyms).
- Links inside a skill are relative to its **rendered** location
  (`.claude/skills/<prefix>.<name>/SKILL.md`): other skills as `../{{PREFIX}}.code/SKILL.md#…`,
  project docs as `../../../ai/conventions.md#…`. Anchors must exist; the smoke test checks them.
- `template/skills/security-audit/` is Cloudflare's skill vendored as-is except the `name` line.
  Refresh it by diffing against upstream and update `UPSTREAM.md`; never edit its content.
- A new skill = folder under `template/skills/` + line in `template/manifest` + mention in
  `setup/SETUP.md` (round 3 or the default `SDD_SKILLS`) + row in both README tables + CHANGELOG.
- `bin/sdd` depends on bash 4, git, tar and coreutils only — no jq, node or python. Writes go
  through `install_file` (atomic replace, safe for the running script). Scaffold files are never
  auto-merged. Keep `sdd help` (the header comment) accurate.
- Changes to `template/project/`, `_dev.template.md` or `setup/` are not merged into projects:
  write them so `/<prefix>.update` can propose them, and list them in the CHANGELOG.

## Before finishing any change

- `bash scripts/smoke-test.sh` passes (renders a demo project, customizes it, updates to a second
  template version, checks merge, conflict, new file, scaffold diff, exit codes, placeholders and
  links).
- `bash -n bin/sdd` is clean when the script changed.
- `grep -rn '{{' template bin setup` shows only the allowed placeholders.
- `CHANGELOG.md` has an entry under `## Unreleased`.
- EN and PT READMEs say the same thing.

## Releasing

Use `/sdd.release` or do it by hand: move `## Unreleased` to `## vX.Y.Z — YYYY-MM-DD`, bump
`SDD_SCRIPT_VERSION` in `bin/sdd`, commit `release: vX.Y.Z`, annotated tag `vX.Y.Z`, push `master`
and the tag. Projects pin a release with `bash .sdd/sdd update --ref vX.Y.Z`.

## Commits

English, imperative subject, area prefix: `skills:`, `agents:`, `scaffold:`, `script:`, `setup:`,
`docs:`, `release:`. One logical change per commit. Commit and push only when asked.
