# Reflect — Prevent + Consolidate + Ship

Runs ONCE per sprint, after all deliverables pass verification.

## 1. Prevention

Read ALL `round-*/verifier/` reports from this sprint. For every bug found:
- Root cause — why did it exist?
- Prevent the CLASS at the highest level: type > lint > gate > test > explorer

## 2. Consolidate

- Update `CLAUDE.md` — test counts, architecture accuracy
- Update `user-contract.json` — raise directional thresholds (test count went up → new minimum)
- Update explorer missions — based on what verifiers found
- Update `REVIEW.md` — add semantic rules from implied requirements

## 3. Ship

- Deploy: test → promote
- Git push
- Log sprint summary

## 4. Next Sprint

`state.json`: `{mode: "plan", round: 0, sprint: N+1}`
