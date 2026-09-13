# Contributing to Learning-Hog

First off, thank you for considering a contribution — every issue, idea, and
pull request is welcome.

By participating in this project you agree to abide by our
[Code of Conduct](CODE_OF_CONDUCT.md).

> [!IMPORTANT]
>
> Please do not open a public issue for security vulnerabilities. Follow the
> [security policy](SECURITY.md) and use private vulnerability reporting
> instead.

## Getting started

1. Fork the repository and create your branch from `main`.
2. Set up a development environment (see below).
3. Make your changes with tests where applicable.
4. Run the local checks and make sure they pass.
5. Open a pull request using the repository's pull request template.

### Development environment

The easiest way to get a full environment is the provided dev container
(described in [.devcontainer/README.md](.devcontainer/README.md)); it ships
Python 3.13, uv, and every tool listed below, and installs the hook runner for
you.

To set up manually you need [uv](https://docs.astral.sh/uv/) and Python 3.13+:

```bash
uv sync --locked --all-groups
prek install
```

`prek install` enables the pre-commit hooks described below.

## Making changes

- Keep pull requests focused: one logical change per pull request.
- New behavior should come with tests in `tests/`.
- If your change touches `src/` or `tests/`, keep cognitive complexity within
  the project's gate (see the commands below).
- Write clear commit messages that explain *why* the change was made.

### Local checks

All of these run locally and in CI; hooks run automatically on commit and push
once `prek install` has been run:

```bash
# Lint and format (must be clean)
uv run ruff check src tests
uv run ruff format src tests

# Type check
uv run ty check src

# Cognitive complexity gate
uv run complexipy src --max-complexity-allowed 15

# Tests
uv run pytest

# Everything the pre-commit stage runs, across all files
prek run --all-files
```

Markdown documentation (including this file) is linted with
[markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) using
[.markdownlint-cli2.jsonc](.markdownlint-cli2.jsonc), and GitHub Actions
workflows are linted with `actionlint`.

### Commit-time and push-time hooks

- `pre-commit` stage: formatting, linting, type checking, the complexity gate,
  markdown and workflow linting, tests on changed Python files, and a private
  key detector.
- `pre-push` stage: a security gate — zizmor (GitHub Actions SAST), osv-scanner
  (dependency vulnerabilities), and gitleaks (secrets in git history).

## Opening issues

Please search existing issues (open and closed) before opening a new one, and
use one of the issue templates:

- **Bug report** — something is broken or behaves unexpectedly.
- **Feature request** — you have an idea for an improvement or new capability.

If your report concerns a security vulnerability, use the channels in the
[security policy](SECURITY.md) instead — do not file a public issue.

## Submitting pull requests

- Reference the related issue in your pull request (e.g. `Fixes #123`).
- Describe what changed and why; the pull request template will prompt you.
- Ensure all local checks pass before requesting review.
- Review is requested from the code owners automatically via
  [.github/CODEOWNERS](.github/CODEOWNERS).

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE.md) that covers this project.
