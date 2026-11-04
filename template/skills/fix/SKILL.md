---
name: {{PREFIX}}.fix
description: Fast path for small changes. Invoked by /{{PREFIX}}.fix or "quick fix / small change / tweak / bug fix / adjust existing feature". Implements a scoped change to an already-specified feature with tests and an inline self-review — creates no new spec, updates an existing one only when code and spec diverge.
model: {{MODEL_IMPLEMENT}}
metadata:
  role: fast-implementer
  related: {{PREFIX}}.code, {{PREFIX}}.review, {{PREFIX}}.go, {{PREFIX}}.reverse
---

# {{PREFIX}}.fix — Scoped fast implementation (no new spec)

The quick lane of the {{PROJECT_NAME}} workflow: implement a **small, bounded change to a feature
that already has a spec**, without running the full `start → tasks → code → review` chain. It
stays quality-equal to full SDD by being **narrow on purpose** — same non-negotiable rules as
`{{PREFIX}}.code`, same self-check as `{{PREFIX}}.review`, folded into one pass.

> Project context and rules: see `CLAUDE.md` and `ai/module_map.md`. Report in {{LANGUAGE}}.

## Scope gate (decide before writing anything)

This skill is only valid when **all** of these hold:

- The change touches surface area **an existing `/specs/<feature>/` already covers** (bug fix,
  copy/i18n tweak, small behavior adjustment, refactor, missing test, follow-up from a review).
- It fits within that spec's requirements and acceptance criteria — you are **not** introducing
  a new capability, flow, or business rule.
- It is bounded (roughly a handful of files in one or two modules).

If any fails — **new capability, no owning spec, or a real business rule changes** — **STOP** and
route to the full flow: `/{{PREFIX}}.go` (or `/{{PREFIX}}.start` for just the spec). Do **not**
invent a spec here. "Never implement a feature without a spec" (`CLAUDE.md`) is not waived by
this skill; it is enforced by this gate.

If the area exists in the code but has no spec (legacy feature), route to `/{{PREFIX}}.reverse`
first — it writes the spec from the current behavior; then come back here. If you can't tell
whether an owning spec exists, say so and ask — don't proceed on a guess.

## How to act

Act as a **Software Engineer** doing a focused change.

1. **Identify the change and its owning feature.** Locate `/specs/<feature>/` and read the parts
   that govern the surface you're touching (`spec.md`, `rules.md`, `flows.md` as relevant).
2. **Run the scope gate above.** Route out if it doesn't pass.
3. **Re-read `/ai/module_map.md`** for the module(s) involved before touching code.
4. **Implement** in the correct app/module/layer, honoring the
   [non-negotiable rules](../{{PREFIX}}.code/SKILL.md#non-negotiable-rules) and the
   [clean code baseline](../{{PREFIX}}.code/SKILL.md#clean-code-baseline-every-line-you-write) of
   `{{PREFIX}}.code` — in short: no behavior outside the spec, thin entry points, business code
   framework-free where required, ports+adapters for integrations, atomic all-or-nothing writes,
   no hand-edited generated code, no hardcoded user-facing strings.
5. **Add/adjust tests** in the owning module for the changed behavior. A fix without a covering
   test is incomplete unless the surface genuinely has no runtime behavior (pure docs/comments).
6. **Sync the spec only if code now diverges from it** (see next section).
7. **Self-review inline** (see next section).

## Spec handling — update, never create

- **Never create a new `/specs/<feature>/`** — that is `/{{PREFIX}}.start`'s (or
  `/{{PREFIX}}.reverse`'s) job. If you feel the urge to, the scope gate failed; route out.
- If the change makes the code **diverge from the existing spec**, apply the project rule
  **fix the spec first** (`CLAUDE.md`): update the minimal part of `spec.md` / `rules.md` /
  `flows.md` that now describes reality, then make the code match. Keep the edit surgical — only
  the rule/criterion that actually changed.
- If nothing diverges, leave the spec untouched.
- Do not touch `tasks.md` — the fast lane doesn't maintain a task checklist.

## Self-review before finishing (inline, do not skip)

Because this lane skips the separate `/{{PREFIX}}.review` step, run its
[mandatory checklist](../{{PREFIX}}.review/SKILL.md#mandatory-checklist) against your own diff —
at minimum: acceptance criteria still hold, correct module/layer per the module map, boundaries
respected, integrations behind port+adapter, all-or-nothing writes atomic, no hardcoded strings,
clean code, tests present. Run the relevant tests and lint
([`/ai/conventions.md#commands`](../../../ai/conventions.md#commands)).

## Security analysis before finishing (do not skip)

After the self-review, run [`{{PREFIX}}.security`](../{{PREFIX}}.security/SKILL.md) scoped to this
diff. Apply any **Critical**/**High** remediation in this run (with a covering test) and re-run it
once. If a Critical/High finding remains, or its fix exceeds this lane's scope, stop and recommend
`/{{PREFIX}}.go`.

If the self-review surfaces anything blocking that you can't resolve within this small scope, stop
and recommend `/{{PREFIX}}.review` (or `/{{PREFIX}}.go`) rather than shipping a partial fix.

## Expected output

- A focused diff in the correct app/module/layer, with covering tests.
- A minimal spec update **only** if code diverged from the spec (report which files).
- A short report: what changed, files touched, spec touched (or "spec unchanged"), and the result
  of the inline self-check and of the security analysis (risk level + open follow-ups). Tests and
  lint green when applicable. Suggest `/{{PREFIX}}.commit`.
