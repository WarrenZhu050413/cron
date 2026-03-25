# Verify — Run All Contracts

The verifiers are the skeptic. Run commands literally. No interpretation. No "I think it passes."

## 1. Run General Verifiers (from user-contract)

These are HARD GATES. If ANY fails → P0. Do not proceed to tick verifiers.

Read `cron/user-contract`, find the `General Verifiers` section. Run each command. Record pass/fail.

```bash
# Example (actual commands come from user-contract):
npx tsc --noEmit                    # pass/fail
npx vitest run                      # pass/fail (check exit code)
curl -sf http://8.135.53.164/health # pass/fail
```

Also check directional verifiers (thresholds that must not regress):
- Test count ≥ threshold
- Type hole count ≤ threshold

**If any general verifier FAILS**: set mode="generate", DO NOT increment round. The failure is a P0 bug — generator must fix it before anything else.

## 2. Run Tick Verifiers (from contract)

Read `cron/contracts/sprint-{N}/contract`, find the `Tick Verifiers` section. Run each command. Score 0-10:

| Score | Meaning |
|-------|---------|
| 0-2 | Not met — file specific bug |
| 3-4 | Partially met — needs more work |
| 5-6 | Met minimally |
| 7-8 | Met well |
| 9-10 | Exceeded expectations |

## 3. Probe for Implied Requirements

Beyond the explicit verifiers, ask: "What SHOULD work that nobody specified?"
- Try edge cases the contract didn't mention
- Test error handling paths
- Check accessibility, performance, security implications
- Score these as bonus findings (don't block, but report)

## 4. Write Verify Report

Write `cron/contracts/sprint-{N}/round-{M}-report`:
```json
{
  "sprint": N, "round": M,
  "general": {"tsc": "pass", "vitest": "pass", "health": "pass"},
  "directional": {"test_count": {"value": 875, "threshold": 867, "status": "pass"}},
  "tick": {
    "deliverable-1": {"score": 8, "status": "pass", "notes": "..."},
    "deliverable-2": {"score": 3, "status": "fail", "bug": "specific issue at file:line"}
  },
  "implied": [{"finding": "edge case X not handled", "severity": "p2"}],
  "tick_average": 5.5,
  "verdict": "fail"
}
```

## 5. Decision

- **General verifier failed** → `mode: "generate"` (same round, must fix P0)
- **Tick average <6** → `mode: "generate"` (same round, retry with bug list)
- **Tick average ≥6** → round++
  - round >6 → `mode: "reflect"` (sprint complete)
  - round ≤6 → `mode: "generate"` (next round)

## Key Rules

- Run commands LITERALLY — copy-paste from contract, check exit code
- A curl returning 500 is a FAIL, not "it's probably fine"
- A vitest with 1 failure is a FAIL, not "mostly passes"
- Bugs must be SPECIFIC: file, line, what's wrong, what's expected
- The verifier does NOT fix — it only reports
- Implied requirement probing makes the contract SMARTER over time
