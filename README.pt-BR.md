# sdd — Template de Spec-Driven Development para Claude Code

[English](README.md)

Um conjunto reutilizável de **skills, agentes e documentos de projeto para Claude Code** que coloca
um projeto num fluxo de Spec-Driven Development (SDD): todo comportamento nasce como spec, o código
é implementado a partir de tarefas, e nada está pronto sem passar por uma revisão de conformidade e
uma análise de segurança.

O template é **renderizado em cada projeto** (as skills ganham o prefixo do projeto, os docs ganham
os fatos do projeto) e pode ser **atualizado a partir deste repositório** com um merge 3-way que
preserva as personalizações do projeto.

## O que vem

| Skill | Função |
|---|---|
| `/<prefixo>.start` | Passo 1 — `spec.md`, `flows.md`, `rules.md` em `/specs/<feature>/` |
| `/<prefixo>.tasks` | Passo 2 — `tasks.md` mapeado para app/módulo/camada, com contrato entre apps |
| `/<prefixo>.code` | Passo 3 — implementa a partir do `tasks.md`, com testes, base de clean code e lint limpo; delega trabalho multi-app aos agentes especialistas |
| `/<prefixo>.review` | Passo 4 — relatório de conformidade com a spec, arquitetura, clean code e qualidade dos testes |
| `/<prefixo>.security` | Passo 5 — checklist AppSec, achados mapeados em OWASP, gate de severidade (nenhum Crítico/Alto aberto) |
| `/<prefixo>.go` | Os cinco passos com check-point de aprovação após cada um |
| `/<prefixo>.express` | Via econômica em tokens para features simples: sem perguntas, sem check-points, pula a review, nunca pula a segurança |
| `/<prefixo>.fix` | Mudança pequena em feature já especificada, com auto-revisão inline e passagem de segurança |
| `/<prefixo>.reverse` | Spec a partir de código existente — traz features legadas para o SDD |
| `/<prefixo>.ask` | Consultor técnico/arquitetura; não escreve código |
| `/<prefixo>.commit` | Um commit limpo por repositório tocado; nunca faz push |
| `/<prefixo>.update` | Sincroniza o projeto com este template |
| `/<prefixo>.screen` (opcional) | Gerador de prompt para telas no Claude Design |
| `/<prefixo>.security-audit` (opcional) | [Cloudflare security-audit](https://github.com/cloudflare/security-audit-skill) vendorizada para auditorias profundas periódicas |

Agentes: `techlead` (sessão principal, conduz as skills e delega) e um especialista `<app>-dev`
por app (gerado no setup) que implementa uma fatia e responde `BLOCKED:` em vez de adivinhar.

Docs do projeto: `CLAUDE.md` (enxuto, sempre carregado), `ai/module_map.md` (onde cada código
mora, checagem de vazamento de lógica), `ai/conventions.md` (comandos, testes, nomenclatura, i18n,
banco, env, commits), `ai/docs-authoring-rules.md` (higiene de tokens), `specs/_template/*`,
`docs/Product.md`.

Princípios embutidos nas skills: specs como única fonte de verdade, clean code, teste para cada
regra de negócio, economia de tokens (arquivos sempre carregados enxutos, detalhe sob demanda,
modelo mais barato na implementação, via express), gates obrigatórios de review e segurança.

## Início rápido

Requisitos: Claude Code, `git`, `bash` 4+.

Abra o Claude Code no projeto (novo ou existente) e cole:

```
Set up Spec-Driven Development in this project from the template at
https://github.com/emersonmendes/sdd. Clone it into a temporary folder, read its
setup/SETUP.md and follow it step by step: interview me first (start by asking which
language I want to use), reverse-engineer the codebase if this is an existing project,
then render and adapt the skills, agents and project docs. Do not commit anything.
```

O prompt é em inglês porque o protocolo de setup é em inglês; a primeira pergunta é o idioma, e dali
em diante a conversa segue no idioma escolhido (por exemplo, português).

O setup vai:

1. Detectar o que o projeto já tem (manifests, apps, scripts).
2. Entrevistar você: idioma, nome do projeto e prefixo das skills, **arquitetura e tecnologias**
   (apps, estilo, dados, integrações, comandos), regras inegociáveis a adotar, skills opcionais,
   convenção de commit, agentes especialistas.
3. Em projeto existente, fazer **engenharia reversa** primeiro
   ([`setup/REVERSE-ENGINEERING.md`](setup/REVERSE-ENGINEERING.md)): `docs/Architecture.md`,
   rascunhos preenchidos de `ai/*.md` e `specs/_inventory.md` (features encontradas, especificadas
   sob demanda com `/<prefixo>.reverse`).
4. Escrever `.sdd/config`, rodar `bin/sdd init`, adaptar os blocos de projeto e o scaffold,
   verificar.

O idioma escolhido vale para conversa, relatórios, commits, `/specs` e `/docs`. Skills, `CLAUDE.md`
e `ai/` ficam em inglês (menos tokens, instruções mais confiáveis).

## Fluxo do dia a dia

```
/<prefixo>.go  <descrição da feature>      # fluxo completo, check-point após cada passo
/<prefixo>.express <feature pequena>       # feature simples, sem perguntas
/<prefixo>.fix <ajuste pequeno>            # mudança em feature já especificada
/<prefixo>.reverse <feature existente>     # escreve a spec do que o código faz hoje
/<prefixo>.ask <pergunta>                  # orientação, sem código
/<prefixo>.commit                          # um commit por repositório tocado
```

Ou rode a sessão principal como tech lead: `claude --agent techlead`.

## Atualizando projetos a partir deste template

Cada projeto registra em `.sdd/config` o commit do template usado na renderização. Para atualizar:

```
/<prefixo>.update         # no Claude Code — roda o script, resolve conflitos, verifica
bash .sdd/sdd update      # ou manualmente; --ref v0.2.0 fixa uma versão
bash .sdd/sdd status      # versão do template, último remoto, arquivos personalizados
bash .sdd/sdd diff        # personalizações do projeto vs. renderização original
```

Como o merge funciona: para cada arquivo gerenciado (skills, agente `techlead`, o próprio script),
a renderização original na versão anterior do template é a base; o arquivo do projeto e a nova
renderização são os dois lados. Arquivos não alterados são substituídos, arquivos personalizados são
mesclados (`git merge-file`), conflitos reais ficam como marcadores para o `/<prefixo>.update`
resolver. Arquivos de scaffold (`CLAUDE.md`, `ai/*`, `specs/_template`, `docs/Product.md`, agentes
`<app>-dev`) pertencem ao projeto: o script reporta as mudanças do template em
`.sdd/last-scaffold.diff` e nunca os sobrescreve.

Personalize as skills dentro dos blocos `<!-- sdd:project -->`; melhorias genéricas pertencem aqui —
`bash .sdd/sdd diff <arquivo>` gera o patch para contribuir.

## Estrutura do repositório

```
bin/sdd                      # init | update | status | diff (bash + git, sem dependências)
setup/SETUP.md               # protocolo que o assistente segue no setup
setup/REVERSE-ENGINEERING.md # como projetos existentes são mapeados antes da renderização
template/manifest            # skills e seus padrões
template/skills/<nome>/      # templates de skill ({{PREFIX}}, {{PROJECT_NAME}}, {{LANGUAGE}}, {{MODEL_*}})
template/agents/             # techlead.md (gerenciado) e _dev.template.md (por app, no setup)
template/project/            # scaffold: CLAUDE.md, ai/, specs/_template/, docs/Product.md
```

Placeholders renderizados pelo script: `{{PREFIX}}`, `{{PROJECT_NAME}}`, `{{LANGUAGE}}`,
`{{MODEL_IMPLEMENT}}`, `{{MODEL_LEAD}}`. Conteúdo específico do projeto fica nos blocos
`<!-- sdd:project -->` e nos arquivos de scaffold.

## Versionamento

Tags seguem semver (`v0.1.0`); veja o [CHANGELOG.md](CHANGELOG.md). Os projetos fixam o commit
renderizado; `sdd update --ref <tag>` fixa uma release.

## Créditos e licença

Extraído das skills do projeto `aqconecta`. A skill opcional `security-audit` é da Cloudflare,
vendorizada sem alterações além do nome (veja `template/skills/security-audit/UPSTREAM.md`).
MIT — veja [LICENSE](LICENSE).
