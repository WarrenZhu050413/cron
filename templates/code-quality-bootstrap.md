# Code Quality Bootstrap

> Run this during initial project setup (Phase C of cron_setup.md).
> For each missing item, create a Sprint 1 deliverable to add it.
> Quality infrastructure is the foundation—build it before features.

## 1. Pre-Commit Gates

Does the project have pre-commit hooks with these layers?

- [ ] **Secret scan** — grep for API keys (`sk-*`), hardcoded passwords
- [ ] **Console.log ratchet** — count must not increase per commit
- [ ] **Lint** — ESLint/Biome/Ruff on staged files only (fast)
- [ ] **Type check** — `tsc --noEmit` / `mypy --strict` / `go vet`
- [ ] **Build verification** — `vite build` / `bun build` / `go build` (conditional on changed files)
- [ ] **Fast tests** — regression suite only (full suite runs on deploy)

**If missing**: create `.husky/pre-commit` (npm/bun), `.pre-commit-config.yaml` (Python), or custom script. Each gate blocks the commit on failure.

**Calibration**:
- fail: no pre-commit hooks
- pass: 4+ gates present and enforced
- high_pass: all 6 gates + gates catch real issues in first round

## 2. Type Safety

- [ ] **Strict mode** — `strict: true` in tsconfig / `mypy --strict` / equivalent
- [ ] **No `any` in core** — lint rule banning `any` in business logic directories
- [ ] **Branded types** for domain IDs — prevents `f(userId, orderId)` vs `f(orderId, userId)` swaps

```typescript
// Pattern: branded types
type Brand<T, B extends string> = T & { readonly __brand: B };
type ProjectId = Brand<number, "ProjectId">;
type UserId = Brand<string, "UserId">;
```

**If missing**: enable strict mode + add `@typescript-eslint/no-explicit-any` as error in `src/core/`.

## 3. Layer Boundaries

Are architectural layers enforced by linting?

- [ ] **Pure logic** separated from side effects (IO at edges, pure in middle)
- [ ] **Database access** through defined interfaces, not scattered `db.query()` everywhere
- [ ] **External API calls** isolated to adapter/client layer
- [ ] **Import restrictions** — lint rules preventing cross-layer imports

```
Typical 3-layer structure:
  src/core/    — pure business logic (no IO, no imports from routes/)
  src/adapters/— database, external APIs, file system
  src/routes/  — HTTP handlers, middleware, side effects
```

**If missing**: define layers + add ESLint `import/no-restricted-paths` or equivalent.

## 4. Test Architecture

- [ ] **Unit tests** for core logic (pure functions, deterministic)
- [ ] **Contract tests** for interfaces/APIs (schema validation, output shapes)
- [ ] **Regression tests** mapped 1:1 to requirements (each requirement has a test file)
- [ ] **Real fixtures** — no mocks for databases (use test DB with known data)

```
test/
  unit/        — pure function tests
  contract/    — interface/schema tests
  regression/  — 1:1 with user_requirements/ or product specs
```

**If missing**: create test directories. Rule: no feature ships without a regression test.

## 5. Design System (if project has UI)

- [ ] **CSS variables** for all colors, spacing, border-radii (tokens.css or equivalent)
- [ ] **No inline styles** — enforce via lint rule
- [ ] **Dark mode** support (`[data-theme="dark"]` or `prefers-color-scheme`)
- [ ] **Shared components** — buttons, modals, tables, badges, form inputs
- [ ] **Page-scoped CSS** — each page/feature gets its own stylesheet, prefixed classes

**If missing**: create tokens.css, add `no-inline-style` lint rule. Reference the `frontend-design` skill for new UI work.

## 6. Hardening Log

- [ ] **`.hardening-log.jsonl`** exists at project root
- [ ] Each tick records: `round`, `timestamp`, `test_results`, `changes`, `findings`, `security_sweep`

```json
{"round": 1, "timestamp": "2026-03-25T10:00:00Z", "tests": "42 pass, 0 fail", "findings": 3, "fixed": 3, "security": "PASS"}
```

**If missing**: create empty file. The reflect phase appends to it after each sprint.

## How to Use

During cron setup, read this file. For each unchecked item:
1. Create a Sprint 1 deliverable: "Bootstrap: {item name}"
2. Calibrate: fail=not present, pass=exists+enforced, high_pass=catches real issues
3. Quality bootstrap deliverables take priority over feature deliverables
