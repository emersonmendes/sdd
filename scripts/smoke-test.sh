#!/usr/bin/env bash
# End-to-end test of the template and bin/sdd. Works on the current working tree.
#   bash scripts/smoke-test.sh
# Scenario: render a demo project (init) → customize two skills → create a v2 of the template
# (one clean change, one conflicting change, a new file, a scaffold change, a script bump) →
# update → assert merge, conflict, new file, scaffold diff, exit codes, status, diff, idempotence.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
fail=0
ok()   { printf '  ok   %s\n' "$*"; }
bad()  { printf '  FAIL %s\n' "$*"; fail=$((fail + 1)); }
check(){ if eval "$2"; then ok "$1"; else bad "$1"; fi; }
gitc() { git -c user.email=smoke@test -c user.name=smoke "$@"; }

echo "== template copy (working tree) → v1"
mkdir -p "$WORK/tpl"
tar --exclude=.git -C "$ROOT" -cf - . | tar -xf - -C "$WORK/tpl"
gitc -C "$WORK/tpl" init -q -b main
gitc -C "$WORK/tpl" add -A
gitc -C "$WORK/tpl" commit -qm "v1"
gitc -C "$WORK/tpl" tag v0.0.1

echo "== init"
P="$WORK/proj"; mkdir -p "$P/.sdd"; gitc -C "$P" init -q -b main
ALL_SKILLS="$(awk '!/^#/ && NF {print $1}' "$ROOT/template/manifest" | tr '\n' ' ')"
cat > "$P/.sdd/config" <<CFG
SDD_PREFIX=demo
SDD_PROJECT_NAME="Demo App & Co"
SDD_LANGUAGE=Português (Brasil)
SDD_SKILLS="$ALL_SKILLS"
CFG
( cd "$P" && bash "$WORK/tpl/bin/sdd" init --template "$WORK/tpl" >/dev/null ); check "init exit 0" "true"
check "config has ref and version" "grep -q '^SDD_TEMPLATE_REF=' '$P/.sdd/config' && grep -q '^SDD_TEMPLATE_VERSION=v0.0.1' '$P/.sdd/config'"
for s in $ALL_SKILLS; do
  [ -f "$P/.claude/skills/demo.$s/SKILL.md" ] || bad "missing rendered skill $s"
  grep -q "^name: demo.$s\$" "$P/.claude/skills/demo.$s/SKILL.md" || bad "frontmatter name of $s"
done; ok "all manifest skills rendered with prefix"
check "techlead agent rendered" "grep -q 'Demo App & Co' '$P/.claude/agents/techlead.md'"
check "scaffold copied" "[ -f '$P/CLAUDE.md' ] && [ -f '$P/ai/module_map.md' ] && [ -f '$P/specs/_template/spec.md' ] && [ -f '$P/docs/Product.md' ]"
check "script installed and executable" "[ -x '$P/.sdd/sdd' ]"
check "no placeholders left" "! grep -rln '{{[A-Z_]*}}' '$P/.claude' '$P/CLAUDE.md' '$P/ai' '$P/specs' '$P/docs' >/dev/null"
check "language rendered" "grep -q 'Português (Brasil)' '$P/.claude/skills/demo.review/SKILL.md'"
( cd "$P" && bash .sdd/sdd init --template "$WORK/tpl" >"$WORK/out" 2>&1 ); check "init keeps existing files" "grep -q 'kept existing: 3[0-9]' '$WORK/out'"

echo "== links and anchors in rendered files"
if command -v python3 >/dev/null; then
  python3 -I - "$P" <<'PY' || bad "link check"
import re, sys, pathlib
root = pathlib.Path(sys.argv[1])
files = [p for p in list(root.glob('.claude/**/*.md')) + [root/'CLAUDE.md'] + list(root.glob('ai/*.md')) if p.is_file()]
def slug(h):
    h = re.sub(r'[^\w\- ]', '', h.strip().lower()); return h.replace(' ', '-')
bad = 0
for f in files:
    for m in re.finditer(r'\]\(([^)\s]+)\)', f.read_text()):
        link = m.group(1)
        if link.startswith(('http', 'mailto')): continue
        path, _, anchor = link.partition('#')
        t = (f.parent / path).resolve() if path else f.resolve()
        if not t.exists(): print(f'  missing file   {f.relative_to(root)}: {link}'); bad += 1; continue
        if anchor and t.suffix == '.md':
            heads = [slug(re.sub(r'^#+\s*', '', l)) for l in t.read_text().splitlines() if l.startswith('#')]
            if anchor not in heads: print(f'  missing anchor {f.relative_to(root)}: {link}'); bad += 1
print(f'  ok   links checked in {len(files)} files' if not bad else f'  FAIL {bad} broken link(s)')
sys.exit(1 if bad else 0)
PY
else
  echo "  skip link check (python3 not found)"
fi

echo "== customize project, create template v2"
gitc -C "$P" add -A; gitc -C "$P" commit -qm init
sed -i 's#^(setup: add stack-specific implementation notes here.*#- Project note kept by the merge.#' "$P/.claude/skills/demo.code/SKILL.md"
sed -i 's#^- No magic values — named constants or configuration.$#- No magic values — named constants or configuration (project tweak).#' "$P/.claude/skills/demo.code/SKILL.md"
sed -i 's#^Act as a \*\*Spec Architect\*\*.$#Act as a **Spec Architect** (project line).#' "$P/.claude/skills/demo.start/SKILL.md"
gitc -C "$P" add -A; gitc -C "$P" commit -qm customize
( cd "$P" && bash .sdd/sdd status --template "$WORK/tpl" >"$WORK/out" 2>&1 ); check "status lists 2 customized files" "[ \"\$(grep -c 'customized:' '$WORK/out')\" = 2 ]"

T="$WORK/tpl"
sed -i 's#^- Small functions with one responsibility; no deep nesting — return early.$#- Small functions with one responsibility; no deep nesting — return early. (v2)#' "$T/template/skills/code/SKILL.md"
sed -i 's#^Act as a \*\*Spec Architect\*\*.$#Act as a **Spec Architect** (template v2 line).#' "$T/template/skills/start/SKILL.md"
echo "- (v2) new scaffold line" >> "$T/template/project/CLAUDE.md"
printf '# Notes\nnew in v2\n' > "$T/template/skills/ask/NOTES.md"
sed -i 's#^SDD_SCRIPT_VERSION=.*#SDD_SCRIPT_VERSION="9.9.9"#' "$T/bin/sdd"
gitc -C "$T" add -A; gitc -C "$T" commit -qm v2; gitc -C "$T" tag v0.0.2

echo "== update"
set +e; out="$(cd "$P" && bash .sdd/sdd update --template "$T" 2>&1)"; rc=$?; set -e
check "update exit 2 on conflict" "[ $rc -eq 2 ]"
check "merged skill reported" "printf '%s' \"\$out\" | grep -q 'merged (customized + template changes): .claude/skills/demo.code/SKILL.md'"
check "conflict reported" "printf '%s' \"\$out\" | grep -q 'CONFLICT.*demo.start/SKILL.md'"
check "new file reported" "printf '%s' \"\$out\" | grep -q 'created (new in template): .claude/skills/demo.ask/NOTES.md'"
check "scaffold diff reported" "printf '%s' \"\$out\" | grep -q 'last-scaffold.diff' && grep -q 'new scaffold line' '$P/.sdd/last-scaffold.diff'"
check "merge kept both sides in code skill" "grep -q '(v2)' '$P/.claude/skills/demo.code/SKILL.md' && grep -q 'project tweak' '$P/.claude/skills/demo.code/SKILL.md' && grep -q 'Project note kept' '$P/.claude/skills/demo.code/SKILL.md'"
check "conflict markers in start skill" "grep -q '^<<<<<<< project' '$P/.claude/skills/demo.start/SKILL.md' && grep -q '^>>>>>>> template-new' '$P/.claude/skills/demo.start/SKILL.md'"
check "new file installed" "grep -q 'new in v2' '$P/.claude/skills/demo.ask/NOTES.md'"
check "script replaced" "grep -q '^SDD_SCRIPT_VERSION=\"9.9.9\"' '$P/.sdd/sdd'"
check "config advanced to v0.0.2" "grep -q '^SDD_TEMPLATE_VERSION=v0.0.2' '$P/.sdd/config'"
( cd "$P" && bash .sdd/sdd status --template "$T" >"$WORK/out" 2>&1 ); check "status flags conflict markers" "grep -q 'leftover placeholders or conflict markers' '$WORK/out'"
( cd "$P" && bash .sdd/sdd diff --template "$T" .claude/skills/demo.code/SKILL.md >"$WORK/out" 2>&1 ); check "diff shows customization" "grep -q '^+.*project tweak' '$WORK/out'"
( cd "$P" && bash .sdd/sdd update --template "$T" >"$WORK/out" 2>&1 ); check "update is idempotent" "grep -q 'already at v0.0.2' '$WORK/out'"
check "pin by tag works" "cd '$P' && sed -i 's/^SDD_TEMPLATE_REF=.*/SDD_TEMPLATE_REF=$(git -C "$T" rev-parse v0.0.1)/' .sdd/config && git checkout -q -- .claude && bash .sdd/sdd update --template '$T' --ref v0.0.2 >/dev/null 2>&1; grep -q '^SDD_TEMPLATE_VERSION=v0.0.2' .sdd/config"

echo "== template hygiene"
check "only rendered placeholders in skills, scaffold, techlead, bin" "! grep -rhoE '\{\{[A-Z_]+\}\}' '$ROOT/template/skills' '$ROOT/template/project' '$ROOT/template/agents/techlead.md' '$ROOT/bin' | sort -u | grep -vE '^\{\{(PREFIX|PROJECT_NAME|LANGUAGE|MODEL_IMPLEMENT|MODEL_LEAD)\}\}$' | grep -q ."
check "only known tokens in setup/ and _dev.template.md" "! grep -rhoE '\{\{[A-Z_]+\}\}' '$ROOT/setup' '$ROOT/template/agents/_dev.template.md' | sort -u | grep -vE '^\{\{(PREFIX|PROJECT_NAME|LANGUAGE|MODEL_IMPLEMENT|MODEL_LEAD|APP|APP_ROLE|APP_PATH|APP_STACK|TEST_CMD|LINT_CMD)\}\}$' | grep -q ."
check "manifest skills all exist" "for s in $ALL_SKILLS; do [ -d '$ROOT/template/skills/'\$s ] || exit 1; done"
check "bin/sdd syntax" "bash -n '$ROOT/bin/sdd'"

echo
if [ "$fail" -eq 0 ]; then echo "SMOKE TEST PASSED"; else echo "SMOKE TEST FAILED ($fail)"; exit 1; fi
