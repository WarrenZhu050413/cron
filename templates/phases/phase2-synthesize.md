# Phase 2: Synthesize + Workplan (~1 min)

Read ALL explorer reports. Cross-reference findings. Build workplan.

## Process

1. **Collect** all Finding[] from explorers
2. **Load carry-forward** from last tick (`cron/logs/rounds/tick-N-carryforward.json`). Auto-elevate priority: P3→P2, P2→P1, P1→P0.
3. **Cross-reference**: e.g., harness failure + codebase gap → single root cause. Collapse duplicates.
4. **Build streams**: For each stream: `{ domain, task, files_to_modify, explorer_refs, priority }`
5. **File ownership**: Ensure no two streams touch the same files (reduce merge conflicts)

## Default Streams

| Stream | Domain | Mode |
|--------|--------|------|
| 1 | Core logic fixes | foreground |
| 2 | UI/UX, frontend | foreground |
| 3 | Security, performance, backend | foreground |
| 4 | New feature / requirement | foreground |
| 5 | Tests + docs + cleanup | background |

Dynamic allocation: no findings in a stream → reallocate. Many findings → split into sub-streams.

## Output

A workplan ready for Phase 3 — each stream has specific findings, file:line refs, and a commit message template.
