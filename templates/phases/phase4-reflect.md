# Phase 4: Reflect

**Purpose:** Strengthen the system so fixed bugs cannot recur. This phase **executes** — it launches agents that write prevention code, not just plans.

## A. Prevention — MANDATORY for every bug (push enforcement up the hierarchy)

**Every bug found this tick MUST trigger `cron/protocols/bug-regression-prevention.md`.** A fix without prevention is half the job. The goal is to make the entire CLASS of bug impossible, not just fix this instance.

For each fix, ask: "Can I make this bug class impossible?" Then execute:

- Write a **compiler rule** or **type constraint** that catches it at write time
- Write a **linter rule** that catches it at lint time
- Add a **pre-commit gate** that catches it at commit time
- Add a **contract test** that catches it at test time
- Add an **explorer SOP script** that catches it at review time
- Promote existing checks up the hierarchy (test → lint rule, explorer → gate)

## B. System Optimization

- Expand explorer missions that returned green (green = scope too narrow, not "domain is clean")
- Optimize DevOps: build speed, deploy pipeline, health checks
- Optimize the type system: tighten types, enforce unions, branded types
- Review server infrastructure: caching, rate limiting, monitoring

## C. Load Balancing Analysis

- Which explorers were stragglers? Why? (too broad, external calls, large scan surface)
- Split slow explorers into smaller, focused ones
- Which execution agents conflicted on the same files? Restructure finding groups
- Track agent completion times — target uniform duration

## D. Knowledge Persistence

- **Auto-memory**: Review and update auto-memory files. Add learnings, remove stale entries.
- **CLAUDE.md**: Keep accurate — test counts, architecture, deploy instructions. This is the authoritative project reference.
- **Constitution** (`cron/constitution.md`): Update if procedures changed.
- **Explorer missions**: Sharpen missions that found nothing, expand missions that found a lot.

## E. Carry-Forward

Write unfixed findings to `cron/logs/rounds/tick-N-carryforward.json`. These auto-elevate priority at next tick's Phase 2.

Format:
```json
[
  {"id": "finding-id", "severity": "p1", "description": "...", "reason_unfixed": "..."}
]
```

Launch parallel agents for A, B, C, and D. This phase produces code, not just notes.
