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
5. Open a pull request using one of the repository's two pull request
   templates (described under Submitting pull requests below).

### Development environment

The easiest way to get a full environment is the provided dev container
(described in [.devcontainer/README.md](.devcontainer/README.md)); it ships
Python 3.13, uv, and every tool listed below, and installs the prek runner
for you (the `prek install` step below is what activates the hooks).

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
- **Documentation issue** — something in the docs is missing, wrong, or
  misleading.

If your report concerns a security vulnerability, use the channels in the
[security policy](SECURITY.md) instead — do not file a public issue.

## Submitting pull requests

- Reference the related issue in your pull request (e.g. `Fixes #123`).
- Describe what changed and why; the pull request template will prompt you.
- Ensure all local checks pass before requesting review.
- Review is requested from the code owners automatically via
  [.github/CODEOWNERS](.github/CODEOWNERS).

GitHub shows a template chooser when you open a pull request:

- **Default pull request template** — for typical contributions. It asks for
  a summary, linked issues, the type of change, and the checks you ran.
- **Agent-assisted pull request template** — for pull requests where AI
  tooling did substantial work. It adds required AI disclosure, a human
  understanding attestation, and evidence of a closed verification loop.

## AI-assisted contributions

This project is built with AI assistance and welcomes AI-assisted
contributions. The rules below exist because unverifiable AI output wastes
maintainer time; they set a bar of understanding and evidence, not a ban on
tools.

- **Disclose.** Any AI assistance beyond trivial editor tab-completion must be
  disclosed in the issue or pull request, naming the tool(s) used and the
  extent of the assistance. The issue forms provide a required field for
  this, and the agent-assisted pull request template does the same for
  pull requests.
- **Stay in the loop.** You, not the tool, are responsible for every line you
  submit. You must be able to explain what your changes do and how they
  interact with the rest of the project without AI assistance.
- **Review and edit.** AI-generated text and code must be reviewed and edited
  by a human before submission. Trim the verbosity and noise; cut anything
  that distracts from the main point.
- **Show evidence.** Verification claims need pasted output, not assertions
  (see the pull request template). If an agent did the work, the loop must be
  closed with real command output: tests failing before the fix and passing
  after, lint and type checks clean.
- **Expect closure without review.** Low-effort, unreviewed AI-generated
  submissions may be closed as spam.

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE.md) that covers this project.
