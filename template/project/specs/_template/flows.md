# Flows — <feature>

End-to-end behavioral flows. One section per flow; steps are numbered and name the actor, the
app/module and the rule applied (`R-n`).

## F-1 — <flow name> (happy path)

1. <Actor> does <action> in <app/screen/endpoint>.
2. <Module> validates <input> (`R-1`).
3. …
Result: <observable outcome>.

## F-2 — <alternative or failure flow>

1. …
Result: <outcome, error shown, state unchanged>.
