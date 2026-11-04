---
name: sdd.release
description: Release the SDD template. Invoked by /sdd.release or "cut a release / tag a version / publish the template". Finalizes the CHANGELOG, bumps the script version, commits, tags and pushes; runs the smoke test first.
metadata:
  role: release-manager
---

# sdd.release — Cut a template release

> Rules: see `CLAUDE.md` (Releasing). Talk to the user in the language they use.

## Gate

- Working tree clean except the release edits; `main` checked out and up to date with `origin`.
- `bash scripts/smoke-test.sh` passes. If it fails, STOP and report — no release on a red test.
- `## Unreleased` in `CHANGELOG.md` is non-empty. If empty, STOP: nothing to release.

## How to act

1. **Pick the version.** If the user gave one, use it. Otherwise propose it from the Unreleased
   entries (breaking change to config, placeholders or script behavior → major while < 1.0 means
   minor; new skill or new script feature → minor; wording and fixes → patch) and confirm with
   `AskUserQuestion`.
2. **Finalize the CHANGELOG**: rename `## Unreleased` to `## vX.Y.Z — <today>` and add an empty
   `## Unreleased` above it.
3. **Bump** `SDD_SCRIPT_VERSION` in `bin/sdd` to `X.Y.Z`.
4. **Commit** `release: vX.Y.Z` with the attribution trailer the environment requires.
5. **Tag**: `git tag -a vX.Y.Z -m "vX.Y.Z"`.
6. **Push** `main` and the tag — only after the user confirmed the release (the invocation counts
   as confirmation when it names the version).
7. **Report**: version, commit hash, tag, and the one-liner projects run to pin it:
   `bash .sdd/sdd update --ref vX.Y.Z`.

## Rules

- Never rewrite history or move an existing tag.
- Never release with leftover `(setup:` text outside `template/project/` and `_dev.template.md`,
  or with placeholders outside the allowed set.
