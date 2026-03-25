# Common Requirements

> Apply to ALL deliverables in ALL sprints.
> Executors follow these. Verifiers check these. Violations block the round.

## UI Changes

- Follow the project's existing design system (CSS variables, component library, design tokens)
- No inline styles—use CSS classes in dedicated stylesheets
- Support dark mode (`[data-theme="dark"]` or `prefers-color-scheme` media query)
- Use shared UI components (buttons, modals, tables, badges)—don't reinvent
- Reference the `frontend-design` skill for any new UI work
- Match existing page spacing patterns (don't add extra padding wrappers)

## Security

- Every route serving user data: verify **ownership** (not just authentication)
- Strip sensitive fields (`password`, `secret`, `token`, `api_key`) from all API responses
- Paginate all list endpoints (cap at project max, typically 200-500)
- Sanitize error messages—never leak stack traces, URLs, or credentials to clients
- Rate-limit all LLM-invoking endpoints (cost abuse prevention)
- Fail-closed: missing scope/permissions → empty results, never unrestricted access
- Parameterize all SQL—no template literal interpolation in queries
- Whitelist allowed fields for external API calls—never spread raw request body

## Code Quality

- Zero mock/placeholder/hardcoded test data in production code
- No hardcoded IDs—resolve dynamically via API, session, config, or env var
- Search for existing patterns before creating new ones (date pickers, form inputs, modals, navigation)
- Prefer editing existing files over creating new ones
- Keep solutions minimal—don't add features, refactoring, or "improvements" beyond what's needed
- Follow the project's commit conventions (conventional commits if configured)

## Testing

- New features need regression tests before shipping
- Bug fixes need a test that would have caught the bug
- Tests use real data/fixtures, not mocks (especially for databases)
- Test count must not decrease between rounds (ratchet)
- Regression tests are mapped 1:1 to requirements/specifications

## Data

- Use the project's primary/canonical database for new queries (not legacy/deprecated DBs)
- Never duplicate data that already exists in an authoritative external system
- All queries must be scoped by user permissions (no unscoped SELECT *)
- Cache with TTL, not indefinitely—stale data is a bug

## Verification (mandatory sequence — no shortcuts)

Every verify round must follow this exact sequence:
1. **Deploy** to test slot or test server — use the project's deploy command (e.g., `bash .claude/scripts/worker/deploy-to-slot.sh --service static`)
2. **Authenticate** with real SSO/auth tokens — use the project's autologin (e.g., `bash .claude/scripts/autologin.sh staff`). Never hardcode tokens or use demo accounts.
3. **Open a real browser** via Playwright — navigate to the deployed test URL with the auth token
4. **Click through every changed flow** — open affected pages, fill forms, submit, check responses, verify dark mode, check error states
5. **Screenshot evidence** — capture key states as proof of verification

Reading code or running unit tests alone is NOT verification. Localhost-only testing is NOT verification. If the project has no test server, this is a Sprint 1 P0 blocker — get one before doing anything else.
