# sdd — Template de Spec-Driven Development para Claude Code

[English](README.md)

Um conjunto reutilizável de **skills, agentes e documentos de projeto para Claude Code** que coloca
um projeto num fluxo de Spec-Driven Development (SDD): todo comportamento nasce como spec, o código
é implementado a partir de tarefas, e nada está pronto sem passar por uma revisão de conformidade e
uma análise de segurança.

O template é **renderizado em cada projeto** (as skills ganham o prefixo do projeto, os docs ganham
os fatos do projeto) e pode ser **atualizado a partir deste repositório** com um merge 3-way que
preserva as personalizações do projeto.

## O que é SDD, e por que usar

**Spec-Driven Development** significa escrever todo comportamento antes de construí-lo: uma spec
curta com objetivo, regras de negócio numeradas, fluxos de ponta a ponta e critérios de aceite
verificáveis. Essa spec é a única fonte de verdade. O código deriva dela por uma cadeia explícita
(spec → tarefas → código → review → segurança), os testes citam as regras que cobrem, e quando a
realidade muda, a spec muda primeiro.

Com um assistente de código por IA essa disciplina se paga rápido:

- **Menos feature errada.** O assistente não pode inferir requisitos. A ambiguidade é resolvida numa
  spec de duas páginas antes de existir código, e não descoberta num diff de quarenta arquivos.
- **Revisões que dá para fazer de verdade.** Você aprova a spec, depois a lista de tarefas, depois o
  código: um check-point por etapa em vez de um "parece bom" no final.
- **Testes que significam algo.** Regras e critérios numerados mapeiam um a um para testes; a etapa
  de review confere que cada regra tem o seu.
- **Contexto que sobrevive à sessão.** Specs, mapa de módulos e convenções vivem em arquivos, então
  uma sessão nova, um colega ou outro modelo recebem as mesmas instruções. Nada importante vive só
  no histórico do chat.
- **Menor custo em tokens.** Arquivos sempre carregados enxutos, detalhe sob demanda, modelo mais
  barato na implementação e uma via express para features simples.
- **Segurança como gate, não como lembrança.** Nada está pronto com um achado Crítico ou Alto
  aberto, e nada é commitado com um segredo, um arquivo de credencial, dado pessoal real ou um
  controle de segurança desativado no diff.
- **Código legado incluído.** A `reverse` escreve a spec do que o código existente faz hoje, e
  features antigas passam a ter o mesmo tratamento das novas.

Pule em protótipos descartáveis e scripts de uma vez só. Use em qualquer coisa que você vai manter.

## O que vem

| Skill | Função |
|---|---|
| `/<prefixo>.start` | Passo 1 — `spec.md`, `flows.md`, `rules.md` em `/specs/<feature>/` |
| `/<prefixo>.tasks` | Passo 2 — `tasks.md` mapeado para app/módulo/camada, com contrato entre apps |
| `/<prefixo>.code` | Passo 3 — implementa a partir do `tasks.md`, com testes, base de clean code e lint limpo; delega trabalho multi-app aos agentes especialistas |
| `/<prefixo>.review` | Passo 4 — relatório de conformidade com a spec, arquitetura, clean code e qualidade dos testes |
| `/<prefixo>.security` | Passo 5 — checklist AppSec (controle de acesso, injeção, segredos, exposição de dados, higiene do repositório, supply chain), achados mapeados em OWASP, gate de severidade (nenhum Crítico/Alto aberto) |
| `/<prefixo>.go` | Os cinco passos com check-point de aprovação após cada um |
| `/<prefixo>.express` | Via econômica em tokens para features simples: sem perguntas, sem check-points, pula a review, nunca pula a segurança |
| `/<prefixo>.fix` | Mudança pequena em feature já especificada, com auto-revisão inline e passagem de segurança |
| `/<prefixo>.reverse` | Spec a partir de código existente — traz features legadas para o SDD |
| `/<prefixo>.ask` | Consultor técnico/arquitetura; não escreve código |
| `/<prefixo>.commit` | Varredura de vazamento no diff staged (segredos, arquivos proibidos, dados reais, controles enfraquecidos, dependências não confiáveis), depois um commit limpo por repositório tocado; pergunta antes de fazer push |
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
modelo mais barato na implementação, via express), gates obrigatórios de review, segurança e
varredura de vazamento.

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
/<prefixo>.commit                          # um commit por repositório tocado, depois pergunta se faz push
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

Nota de segurança: o `sdd update` substitui o `.sdd/sdd` pelo script do template e reescreve as
skills gerenciadas, então aponte `SDD_TEMPLATE_REPO` só para um repositório em que você confia (o
seu próprio fork é um bom padrão) e revise o diff antes de commitar uma atualização.

## Estrutura do repositório

```
bin/sdd                      # init | update | status | diff (bash + git, sem dependências)
scripts/smoke-test.sh        # teste de ponta a ponta do template e do script
CLAUDE.md, .claude/skills/   # regras e a skill de release para trabalhar neste repo com Claude Code
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

## Desenvolvendo o template

Abra o Claude Code neste repositório: o `CLAUDE.md` traz as regras de edição (skills genéricas,
placeholders permitidos, gates que nunca podem ser enfraquecidos, convenção de links) e o
`/sdd.release` corta uma release. Antes de commitar uma mudança:

```
bash scripts/smoke-test.sh   # renderiza um projeto demo, personaliza, atualiza para uma v2, checa merge/conflito/links
```

## Versionamento

Tags seguem semver (`v0.1.0`); veja o [CHANGELOG.md](CHANGELOG.md). Os projetos fixam o commit
renderizado; `sdd update --ref <tag>` fixa uma release.

## Créditos e licença

MIT — veja [LICENSE](LICENSE). A skill opcional `security-audit` é da Cloudflare
([cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill), MIT),
vendorizada sem alterações além do nome; a licença dela vai dentro da própria pasta
(`template/skills/security-audit/LICENSE`, veja o `UPSTREAM.md` lá).
