# Module Map — {{PROJECT_NAME}}

Where each type of code belongs. **Consult this file before touching any module.**

(setup: 3–6 lines describing the repositories/apps and how they communicate, including hard
boundaries and anything that does not exist yet by decision — e.g. "no async workers until a spec
adds them". Delete this paragraph.)

## Repositories / apps

| App / layer | Repository / path | Stack | Owns |
|---|---|---|---|
| (setup: one row per app/layer, including shared types/contracts if any) | | | |

## Architecture style and rigor levels

(setup: describe the architecture the project follows. Recommended default — "pragmatic
hexagonal: hexagonal where it hurts, simple where it doesn't", three levels of rigor:

**Level 1 — Volatile external integrations → true ports & adapters.** Payment providers, email,
storage, third-party APIs. One port (interface owned by the business code) and one adapter per
provider; business rules testable without the real service.

**Level 2 — Domain with relevant business logic → rich domain, isolated from the framework.** Any
module whose spec defines non-trivial rules/invariants (state machines, money, permissions).
Business logic in domain + application code without framework or persistence imports; most tests
live here.

**Level 3 — Simple CRUD → direct layers, no ceremony.** Lookup tables, simple catalogs:
entry point → service → persistence directly. No ports or domain entities — that would be
boilerplate with no return.

Adapt the levels to the project's real style — layered MVC, clean architecture, feature folders —
but keep the principle: rigor proportional to the business rules at stake.)

### Layout of a business module

```text
(setup: the canonical folder layout of a module/feature in this project, with one-line comments
per folder — e.g. domain/ (entities, rules, ports), application/ (use cases), infra/ (adapters,
http/entry points, config), <module>.module file (wiring))
```

- **Dependency direction**: (setup: e.g. `infra → application → domain`; the domain knows only its
  own ports.)
- **Wiring**: (setup: how ports bind to adapters — DI container, factories, manual composition.)
- **Shared technical modules**: (setup: list cross-cutting modules such as persistence client,
  health, config, crypto, and who may import them.)

## Where each thing belongs

| Code type | Location |
|---|---|
| Business rule / invariant | (setup) |
| Use case / orchestration | (setup) |
| External integration interface (port) | (setup) |
| Integration implementation / repository (adapter) | (setup) |
| Entry point (controller / route / command / handler) | (setup) |
| Contract shared between apps | (setup) |
| UI component / page / hook | (setup, or N/A) |
| UI copy (i18n) | (setup, or N/A) |
| Database schema / migration | (setup) |
| Configuration / env loading | (setup) |
| Tests | (setup: per app — where unit, integration and e2e tests live) |

## Logic leakage check (before finalizing any change)

- Entry points contain no business logic — they validate, authorize, map and delegate.
- Integration adapters decide no business rules — they only translate protocol/provider.
- Shared types/contracts do not compute rules, prices, or permissions.
- Clients/UI do not duplicate service/domain logic.
- Business/domain code does not import framework or persistence libraries where the rigor level
  requires it.
- Tests assert behavior **defined in the spec**, not inferred behavior.
- Writes the spec requires to be all-or-nothing run in **one transaction**.
(setup: add project-specific boundaries, one line each — e.g. "the UI never calls the API
directly; all traffic goes through the BFF", "the mobile shell holds no business logic". Delete
this paragraph.)
