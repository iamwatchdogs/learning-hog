# Learning-Hog

A CLI that gathers valuable learning resources for any concept
(uv-managed Python 3.13, src layout, package `learning_hog`).

## Commands

- Sync: `uv sync --locked`
- Lint: `uv run ruff check src tests` (format: `uv run ruff format src tests`)
- Types: `uv run ty check src` (strict; warnings are errors)
- Complexity: `uv run complexipy src --max-complexity-allowed 15`
- Tests: `uv run pytest` (coverage + xdist come from addopts)
- Single test: `uv run pytest tests/test_main.py -k name -n 0 --no-cov`
- Hooks: `prek run --all-files` (pre-push security gate:
  `prek run --hook-stage pre-push --all-files`)
- Style config lives in pyproject.toml - read it, do not restate it

## Testing instructions

- Tests live in tests/, mirroring src/ modules.
- HTTP: mock with respx (httpx). Time: freeze with time-machine.
- Snapshots: syrupy. Add or update tests for every change, unasked.
- Never delete or weaken a test to make the suite pass.

## Boundaries

- Never commit secrets; never commit directly to main.
- Ask before adding dependencies or changing pyproject.toml.
- Never hand-edit uv.lock or files under .github/ without running
  actionlint; workflows are pinned by commit SHA.
- Do not create abstractions for one implementation (complexipy gate).

## Workflow

- Verify claims by fetching sources before relying on them; if
  uncertain about anything, research it before implementing.
- Run lint + types + tests before declaring work done; show the output.

## PR instructions

- Branches: `<type>/<short-desc>`. Subject: imperative, <= 72 chars.
- Run the full hook set before pushing (pre-push stage includes
  zizmor, osv-scanner, gitleaks).
