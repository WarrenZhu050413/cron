# Security Sweep

> Runs every verify round. Any FAIL blocks the round from passing.

Execute ALL checks below against the project source. Adapt `--include` patterns for the project's language (`.ts`, `.py`, `.go`, etc.).

## 1. Secret Scan

```bash
grep -rn 'sk-[a-zA-Z0-9]\{20,\}' --include='*.ts' --include='*.js' --include='*.py' src/ | grep -v node_modules
grep -rn 'password\s*[:=]\s*["'"'"'][^"'"'"']*["'"'"']' --include='*.ts' --include='*.py' src/ | grep -v '\.test\.' | grep -v '\.env' | grep -v 'schema\|type\|interface\|placeholder'
```

**FAIL** if any matches. Hardcoded secrets/passwords in source code.

## 2. Sensitive Field Exposure

```bash
grep -rn 'password\|secret\|token\|api_key' --include='*.ts' src/ | grep -i 'json\|response\|return\|res\.' | grep -v 'strip\|delete\|omit\|exclude\|redact\|\.test\.'
```

**WARN** if password/secret/token fields appear in response paths without stripping.

## 3. Unbounded Queries

```bash
grep -rn '\.all(' --include='*.ts' src/ | grep -v 'LIMIT\|limit\|paginate\|slice\|\.length\|\.test\.'
```

**WARN** if `db.query().all()` without LIMIT — potential memory bomb on large tables.

## 4. Raw Error Exposure

```bash
grep -rn 'getErrorMessage\|error\.message\|err\.message\|\.stack' --include='*.ts' src/ | grep -i 'response\|res\.\|json(' | grep -v '\.test\.'
```

**WARN** if error messages/stacks forwarded to client responses. Should use safe static strings.

## 5. Missing Auth on Routes

```bash
grep -rn 'app\.\(get\|post\|put\|delete\)\|router\.\(get\|post\|put\|delete\)' --include='*.ts' src/ | grep -v 'withAuth\|withPermission\|requireAuth\|public\|health\|webhook\|\.test\.'
```

**WARN** if routes lack auth middleware. May be intentional (public endpoints) — flag for review.

## 6. Rate Limiting on LLM Endpoints

```bash
grep -rn 'dashscope\|openai\|anthropic\|llm\|chat/stream\|/chat\|/completions' --include='*.ts' src/ | grep -i 'route\|app\.\|router\.' | grep -v 'limiter\|rateLimit\|throttle\|\.test\.'
```

**FAIL** if LLM-invoking endpoints lack rate limiting. Cost abuse vector.

## 7. SQL Injection Surface

```bash
grep -rn '\${\|f".*SELECT\|f".*INSERT\|f".*UPDATE\|f".*DELETE' --include='*.ts' --include='*.py' src/ | grep -i 'query\|sql\|execute' | grep -v '\.prepare\|\.run\|param\|bind\|\.test\.'
```

**FAIL** if template literals/f-strings in SQL without parameterized queries.

## 8. Console.log Audit (Ratchet)

```bash
grep -rn 'console\.log' --include='*.ts' --include='*.js' src/ | grep -v 'node_modules\|\.test\.\|debug' | wc -l
```

**Track as ratchet** — count must not increase between rounds. Record in hardening log.

## Scoring

| Result | Score | Action |
|--------|-------|--------|
| 0 FAILs + 0 WARNs | 10/10 | PASS |
| 0 FAILs + WARNs | 7/10 | PASS with notes — WARNs become next-sprint deliverables |
| Any FAIL | BLOCK | Round cannot pass. Fix immediately or escalate. |

## How to Use

The **verify phase** calls this sweep after checking all deliverables. Results go into the verifier's `_general.json` report under `"security_sweep"`.

Security FAILs that can't be fixed this round become Sprint N+1 P0 deliverables.
