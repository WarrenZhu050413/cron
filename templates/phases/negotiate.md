# Negotiate — Verify Plan + Tighten Criteria

Loops until clean. Combines plan verification and contract negotiation.

## Check

For each deliverable in `contracts/sprint-{N}/deliverables/`:
1. Does it serve user contract goals?
2. Is the verifier description testable and specific?
3. Does calibration have fail/pass/high_pass with concrete examples?
4. Are deliverables truly independent (no overlapping files)?
5. **10x check**: Is this ambitious enough? Could the generator do more?
6. Is the qualitative description meaningful (not just "it works")?

## If Issues Found

Refine the deliverable JSON. Tighten calibration. Sharpen descriptions. Loop.

## When Clean

`state.json`: `{mode: "generate", round: 1, sprint: N}`
