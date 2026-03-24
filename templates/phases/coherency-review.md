# Coherency Review (every Nth tick — replaces Phases 1-3)

This tick is about system self-improvement, not feature work. The codebase is the machine; this review tunes the machine.

## Phase C0: Parallel Research (3 agents, background)

Launch research agents. Each uses WebSearch to find:

- **Research A**: Competitor updates — what tools exist in this domain? What features do they have?
- **Research B**: API + data source discovery — new APIs, data feeds, integrations relevant to the project
- **Research C**: Best practices + industry trends — academic papers, blog posts, new techniques

Save actionable findings to `cron/logs/research/`.

## Phase C1: Requirement Audit + Consolidate

If the project uses `user_requirements/` + `test/regression/` pattern:

1. **Implementation check**: For each requirement, is the feature actually implemented?
2. **Test check**: Does a matching regression test exist?
3. **Test accuracy**: Does the test verify what the requirement actually asks?
4. **Regression run**: Run all regression tests. Any failure = P0.
5. **Spirit check**: Does the implementation satisfy the spirit of the requirement, not just the letter?
6. **Gap report**: Requirements with no implementation, no test, or weak tests become execution tasks.

**Consolidate:**
- Dead code, stale branches, duplicate logic — delete
- Tests: merge overlapping, delete dead
- Documentation: consolidate scattered findings

## Phase C2: Optimize

- Straggler analysis (which explorer/stream is slowest?)
- Server performance profiling
- Deploy, test, build speed

## Phase C3: Adversarial

- Injection attacks (SQL, XSS, command), oversized requests, null bytes
- Concurrent request stress test
- Rate limiting verification
- Auth/permission edge cases

## Phase C4: Self-Improve + Explorer Evolution + Rotation

This is the PRIMARY self-learning mechanism.

### 4a. Trend Analysis + Memory

1. Analyze `cron/logs/summary.jsonl` trends (recurring failures, slow ticks, patterns)
2. Staleness audit of auto-memory — delete outdated entries
3. Write new learnings to appropriate memory files

### 4b. Rejuvenation Agents (5 agents, parallel)

Launch 5 strategic insight agents:

```
R1: "Read summary.jsonl (last 10 ticks). What PATTERN? Improving or going in circles?"
R2: "Read all explorer reports. Which findings keep recurring? That's a systemic issue."
R3: "Compare current codebase to 10 ticks ago. Did we add bloat or reduce complexity?"
R4: "Read the test suite. Are tests ACTUALLY hard, or recipe-followable?"
R5: "If a user tested this right now with 5 queries, what would disappoint them?"
```

These produce **strategic insight**, not code.

### 4c. Explorer Rotation

**Constraint: never fewer than 6 active explorers (4 core + 2+ rotating).**

For each **rotating** explorer:
1. Evaluate utility over the last 4 ticks — actionable findings? Purpose still valid?
2. **Rotate out** underperformers: set `Active?` to `POOL`
3. **Rotate in** from pool: set `Active?` to `YES`
4. **Rewrite** stale mission.md files
5. **Create new pool explorers** for observation gaps

**Rotation rules:**
- Max 2 rotations per coherency review (stability)
- Explorer must run ≥4 ticks before being eligible for rotation
- Core explorers (E1-E4) are NEVER rotated — only their missions can be sharpened

### 4d. Hook + Automation Gap Analysis

Ask: "Is there repeated manual work a hook could automate?"

## Phase C5: Protocol + Documentation Review

1. Re-read `cron/constitution.md` — do principles still apply?
2. Check `cron/protocols/` — are protocols still accurate?
3. Verify `cron_tick.md` is still correct
4. Check phase files match current reality
5. **CLAUDE.md staleness check**: Verify accuracy — counts, architecture, deploy instructions. Update stale items.
