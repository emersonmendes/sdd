---
name: {{PREFIX}}.commit
description: Commit helper. Invoked by /{{PREFIX}}.commit or "commit / commit this / create the commits". Creates one well-formed commit per touched repository following the project's commit convention; never pushes.
metadata:
  role: committer
  related: {{PREFIX}}.go, {{PREFIX}}.express, {{PREFIX}}.fix
---

# {{PREFIX}}.commit — One clean commit per repository

Turns the current working tree into clean commits — one per touched repository (one commit for a
single-repo project) — following the
[commit convention](../../../ai/conventions.md#commit-convention) in `ai/conventions.md`.

> Project context: see `CLAUDE.md`. Commit messages in the language the convention states
> (default: {{LANGUAGE}}).

## Gate

- Commit only work that is **done** per the lane that produced it: tests green, lint clean, no
  open Critical/High security finding. If the last report says otherwise, **STOP** and say so.
- **Never push.** Never amend or rewrite history unless the user explicitly asks for it.
- Never commit secrets, `.env*` files, credentials, or real personal data. If any is staged,
  unstage it and report.

## How to act

1. Run `git status` in each repository of the project (the list is in `ai/module_map.md`; a
   single-repo project has one). Identify which repositories have changes.
2. For each touched repository, group the changes that belong to the current feature/fix. If the
   tree also holds **unrelated** changes, ask the user (`AskUserQuestion`) whether to include,
   leave or stash them — never commit unrelated work silently.
3. Review the staged diff once (`git diff --staged --stat`, then the hunks you have not seen):
   no debug output, no leftover placeholders or conflict markers, no generated or ignored files.
4. Write the message per the convention: subject in the imperative, what and why, feature
   slug/scope when the convention asks for it, ≤ 72 characters; a body only when the subject
   cannot carry the why; keep the attribution trailer the environment adds (e.g.
   `Co-Authored-By`).
5. Commit each repository separately, provider before consumer (e.g. API before UI), and the
   repository holding `/specs` last so its message can reference the others.
6. Report: repository, short hash, subject, number of files; and anything left uncommitted with
   the reason.

## Expected output

The list of commits created (repository, short hash, subject) and what was intentionally left
uncommitted. No push.
