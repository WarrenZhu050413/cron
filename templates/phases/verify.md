# Verify — Parallel Verifiers Score Against Contract + User Contract

Launch up to 15 verifier sub-agents in ONE message. All parallel. Each verifier is a SKEPTIC.

## 1. User Contract Compliance

One verifier checks quality bars from `user-contract.json`:
- Technical bar: tests pass? types clean? prod healthy?
- Product bar: judgments interpretable? feedback buttons? no emoji?
Writes `contracts/sprint-{N}/round-{M}/verifier/_general.json`

## 2. Deliverable Verification

One verifier per deliverable. Each:
- Reads deliverable JSON (description + calibration)
- **Tests LIVE** — curl production, send real queries, run the test file, navigate the UI
- Scores against calibration: does it match fail, pass, or high_pass?
- Writes **qualitative** assessment — not just "test passed" but how the experience FEELS
- Files specific bugs with file:line if score < pass
- Notes implied requirements the plan didn't mention
- Writes `contracts/sprint-{N}/round-{M}/verifier/{deliverable}.json`

## 3. Calibration

Each verifier reads `scoring-rubric.md` for grading calibration. Read previous rounds' reports to maintain consistency. Don't grade lenient — if it doesn't match the calibration's "pass" example, it's not a pass.

## 4. Summary

Write `contracts/sprint-{N}/round-{M}/_summary.json`:
```json
{
  "sprint": N, "round": M,
  "scores": {"deliverable-1": 7, "deliverable-2": 4, ...},
  "all_pass": false,
  "failed": ["deliverable-2"],
  "quality_bars": {"technical": "pass", "product": "pass"}
}
```

## 5. Decision

- ANY deliverable failed → `{mode: "generate", round: M}` (retry with bug list)
- ALL pass → `{mode: "reflect", sprint: N}`
