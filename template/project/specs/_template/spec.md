# Specification Template

Every system behavior specification must be created from this template and stored under
`/specs/<feature>/spec.md`. Number acceptance criteria (`AC-1`, `AC-2`, …).

## Objective

Describe the user-visible or system-visible outcome this specification owns.

## Context

Explain why this behavior exists, who depends on it (actors/roles), and which apps, modules and
external systems participate.

## Business Rules

Summarize the authoritative rules and link to `rules.md`, where each rule is numbered (`R-n`).
Do not place business rules in code, adapters, generated clients, UI, or tests without
referencing a rule here.

## Functional Requirements

Describe the required behavior in observable terms (API contracts, UI behavior, side effects).

## Non-functional Requirements

Performance, reliability, security, auditability, compatibility, data protection and operational
requirements. Flows that write several related records must state their consistency/transactional
expectations.

## Acceptance Criteria

Verifiable criteria that implementation and tests must satisfy. One line each, numbered `AC-n`.

## Edge Cases

Boundary conditions, failure cases, invalid inputs, retries, idempotency, duplicate events,
unavailable integrations, concurrency and data conflicts.

## Out of Scope

Explicitly state behavior this specification does not define.
