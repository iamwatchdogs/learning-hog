# Learning-Hog

A CLI that gathers valuable learning resources for any concept
(uv-managed Python 3.13, src layout, package `learning_hog`).

**Status: early WIP.** Only the CLI skeleton exists; `find` is a stub and
no resource adapters have landed yet. The package version (1.0.0) runs
ahead of reality - do not treat it as a feature-completeness signal.

## Commands

- Sync: `uv sync --locked`
- Lint: `uv run ruff check src tests`
- Format check: `uv run ruff format --check src tests` (repair with
  `uv run ruff format src tests`). CI runs lint but skips the format
  hook, so run this check before pushing.
- Types: `uv run ty check src` (strict; warnings are errors)
- Complexity: `uv run complexipy src --max-complexity-allowed 15`
- Tests: `uv run pytest` (coverage + xdist come from addopts)
- Single test: `uv run pytest tests/test_main.py -k test_help_lists_find -n 0 --no-cov`
- Hooks: `prek run --all-files` (pre-push security gate:
  `prek run --hook-stage pre-push --all-files`). If hooks do not fire on
  commit or push, run `prek install` (the dev container does this for you).
- Style config lives in pyproject.toml - read it, do not restate it.
  This command list is the canonical copy; CONTRIBUTING.md points here.

## Failure ledger and known traps

Codified from this repo's history; do not re-trip them:

- Known trap (no logged incident yet): Typer callback/option signatures
  legitimately need positional bools and bool defaults, which ruff's FBT
  rules flag. Keep the existing `ruff: ignore[...]` comments (see
  `_version_callback` in `src/learning_hog/main.py`); do not fight ruff
  or delete the comments.
- Commit 8eb9eb5: the documented single-test example once used a `-k`
  filter that matched no test, so a fresh agent hit pytest exit 5 and
  misread it as a broken suite. Verify any `-k` filter matches a real
  test before running or documenting it.

## Testing instructions

- Tests live in tests/, mirroring src/ modules.
- Add or update tests for behavior changes where applicable, unasked.
  Documentation-only changes need no tests; when a behavior change is
  genuinely untestable, say so instead. Never delete or weaken a test
  to make the suite pass.
- Tests must never touch the public internet: mock HTTP with respx
  (httpx) or use local servers and fixtures.
- Not yet used; add with the first test that needs them: time frozen
  with time-machine, snapshots with syrupy.

## Boundaries

- Never commit secrets; never commit directly to main.
- Ask before adding dependencies or changing pyproject.toml.
- Never hand-edit uv.lock or files under .github/ without running
  actionlint; workflows are pinned by commit SHA.
- No abstractions for a single implementation; that is a review rule,
  not a tool gate. Ruff and complexipy separately enforce function-size
  and cognitive-complexity limits.

## Workflow

- Verify claims by fetching sources before relying on them; if
  uncertain about anything, research it before implementing. When
  external research drives a durable product or architecture decision,
  record the evidence under docs/ so the reasoning stays auditable.
- Run lint + format check + types + tests before declaring work done;
  show the output.
- Follow the AI policy in CONTRIBUTING.md. For PRs where AI did more
  than trivial editor completion, use the agent-assisted pull request
  template (disclosure plus evidence); otherwise use the default
  template and disclose the assistance.

## PR instructions

- Branches: `<type>/<short-desc>`. Subject: imperative, <= 72 chars.
- Never open a PR unless the developer asks. Keep one logical change
  per PR; do not let review feedback expand it beyond the original
  goal.
- Run the full hook set before pushing (pre-push stage includes
  zizmor, osv-scanner, gitleaks).
