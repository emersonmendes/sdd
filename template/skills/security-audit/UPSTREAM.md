# Upstream

Vendored copy of Cloudflare's `security-audit` skill
(https://github.com/cloudflare/security-audit-skill, path `skills/security-audit/`), content hash
`98b97aad2873b3b9a8e064007c25e7827b493ba27fda8bfbdb41dab586767973` at the time of vendoring
(2026-11-04).

Local changes: only the frontmatter `name` (rendered as `<prefix>.security-audit` so the project's
`<prefix>.security` skill can invoke it under the project's naming). Everything else is upstream
as-is. To refresh, diff this folder against upstream and keep the `name` line.
