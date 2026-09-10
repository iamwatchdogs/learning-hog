# Dev Container Setup for learning-hog

This directory contains the development container configuration for the
learning-hog project.

## Prerequisites

1. **Docker** installed and running
2. **VS Code** with the **Dev Containers** extension installed
   - Extension ID: `ms-vscode-remote.remote-containers`

## Quick Start

1. Open the project in VS Code
2. When prompted "Reopen in Container", click **Yes** or press `Ctrl+Shift+P` / `Cmd+Shift+P` and run **Dev Containers: Reopen in Container**
3. Wait for the container to build and dependencies to install
4. Start developing!

## What's Included

### Base Environment

- **Python 3.13** (via `ghcr.io/astral-sh/uv` image)
- **uv** package manager (v0.8.6)
- **Linux** (Debian Trixie slim)

### Development Tools (Auto-installed via `uv sync --all-groups`)

- **ruff** - Fast Python linter and formatter
- **ty** - Fast Python type checker (by Astral)
- **pytest** + plugins (pytest-asyncio, pytest-cov, pytest-mock, etc.)
- **complexipy** - Cognitive complexity checker
- **syrupy** - Snapshot testing
- **prek** - Fast pre-commit hook runner (Rust-based, compatible with pre-commit configs)
- **ripgrep (rg)** - Extremely fast code search tool

### Markdown & Workflow Tooling

- **markdownlint-cli2** (via the prek-managed hook) - Markdown/CommonMark
  linter sharing `.markdownlint-cli2.jsonc` with the editor extension below
- **actionlint** (v1.7.12, installed to `/usr/local/bin`) - GitHub Actions
  workflow linter used by the editor extension and manual runs

### VS Code Extensions (Auto-installed)

- **Python** (`ms-python.python`) - Python language support
- **Ruff** (`charliermarsh.ruff`) - Ruff linter/formatter integration
- **Ty** (`astral-sh.ty`) - Ty type checker integration
- **GitHub Actions** (`github.vscode-github-actions`) - CI/CD workflow support
- **actionlint** (`jimeh.actionlint`) - inline GitHub Actions workflow linting
- **markdownlint** (`DavidAnson.vscode-markdownlint`) - Markdown linting sharing
  the same config as pre-commit and CI
- **YAML** (`redhat.vscode-yaml`) - YAML syntax support
- **Better TOML** (`tamasfe.even-better-toml`) - TOML syntax support
- **Coverage Gutters** (`ryanluker.vscode-coverage-gutters`) - Coverage visualization

## Commands

After the container is set up, use these commands:

```bash
# Run the application
uv run python src/learning_hog/main.py --help

# Run tests
uv run pytest

# Run tests with coverage
uv run pytest --cov=learning_hog --cov-report=term-missing

# Lint code
uv run ruff check src tests

# Format code
uv run ruff format src tests

# Type check
uv run ty check src

# Check complexity
uv run complexipy src --max-complexity-allowed 15

# Run pre-commit hooks (via prek)
prek run --all-files

# Lint all markdown files (same rules as pre-commit and CI)
uvx --from markdownlint-cli2 markdownlint-cli2 "**/*.md"

# Lint GitHub Actions workflows
actionlint

# Search code with ripgrep
rg 'pattern' src/          # Search for pattern in src directory
rg -tpy 'import' .        # Search only Python files
rg -n 'TODO' .            # Search with line numbers
rg -C 3 'error' .         # Show 3 lines of context
```

## Project Structure

```text
.devcontainer/
├── Dockerfile          # Container image definition
├── devcontainer.json   # VS Code dev container configuration
├── post-install.sh     # Post-creation setup script
└── README.md           # This file
```

## Environment Variables

The container sets these environment variables:

- `UV_LINK_MODE=copy` - Prevents cross-filesystem copy warnings
- `UV_COMPILE_BYTECODE=1` - Pre-compiles Python bytecode for faster startup
- `UV_PROJECT_ENVIRONMENT=/workspaces/.venv` - Standard venv location
- `PYTHONUNBUFFERED=1` - Ensures Python output is not buffered

## VS Code Settings

The dev container configures VS Code with:

- Python interpreter: `/workspaces/.venv/bin/python`
- Format on save enabled
- Ruff as the formatter and linter
- Ty as the type checker
- Line length ruler at 88 characters (matching `pyproject.toml`)

## Troubleshooting

### Python interpreter not found

If VS Code shows "Python interpreter not found":

1. Open the integrated terminal
2. Run `uv sync --locked`
3. Reload the window (`Ctrl+Shift+P` → "Developer: Reload Window")

### Permission errors

If you encounter permission errors with `.venv`:

- The container runs as root by default for simplicity
- For production use, consider adding a non-root user

### Slow first startup

The first build downloads the base image and installs dependencies. Subsequent
starts are faster due to Docker layer caching.

### Updates

To update the dev container:

1. Modify `.devcontainer/Dockerfile` or `devcontainer.json`
2. Run `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

## Code Search (ripgrep)

This dev container includes **ripgrep (rg)**, an extremely fast code search
tool.

### Why ripgrep?

- ⚡ **Extremely fast** - Multiple times faster than grep, ack, or ag
- 🎯 **Smart defaults** - Respects .gitignore, skips hidden files and binaries
- 🔍 **Code-aware** - Can search by file type with `rg -tpy 'pattern'`
- 🌈 **Color highlighting** - Highlights matches in color
- 📊 **Context support** - Show context around matches with `-C` flag

### Common Usage

```bash
# Basic search
rg 'function_name' src/

# Show files with matches, count matches per file
rg --files-with-matches 'pattern' .
rg --count src/
```

### Ripgrep vs Other Tools

From [ripgrep benchmarks](https://github.com/BurntSushi/ripgrep):

- **ripgrep**: 0.082s (baseline)
- **git grep**: 0.273s (3.3x slower)
- **The Silver Searcher (ag)**: 0.443s (5.4x slower)
- **ack**: 2.935s (35.9x slower)

## Pre-commit Hooks (prek)

This project uses **prek** (a fast, Rust-based pre-commit hook runner) instead
of the traditional `pre-commit` tool.

### What is prek?

- **Fast**: Multiple times faster than pre-commit, uses less disk space
- **Single binary**: No Python runtime required to run prek itself
- **Compatible**: Fully compatible with pre-commit configurations (`.pre-commit-config.yaml`)
- **Manages toolchains**: Downloads Node.js and Go toolchains itself for the
  `markdownlint-cli2` and `actionlint` hooks — no local Node/Go install needed

### Running prek locally

```bash
# Run all pre-commit hooks on all files
prek run --all-files

# Run pre-commit hooks on staged files only (like git commit)
prek run

# Run specific hook
prek run --hook-stage manual ruff-format
```

### CI Integration

The GitHub Actions CI workflow uses `j178/prek-action` to run pre-commit hooks:

- See `.github/workflows/ci.yml` for the CI configuration
- The action runs `prek run --show-diff-on-failure --color=always`
- Skips certain hooks during CI via the `SKIP` environment variable
- Markdown and workflow linting run as dedicated CI jobs (`lint-docs`,
  `lint-workflows`), so their hooks are skipped inside the matrix job

## GitHub Codespaces

This configuration also works with GitHub Codespaces:

1. Go to the repository on GitHub
2. Click **Code** → **Codespaces** → **Create codespace on main**
3. The environment will build in the cloud

## Customization

### Adding System Packages

Edit the `Dockerfile` and add to the `apt-get install` command:

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vim-tiny \
    your-package-here \
    && rm -rf /var/lib/apt/lists/*
```

### Adding VS Code Extensions

Add extension IDs to the `customizations.vscode.extensions` array in
`devcontainer.json`:

```json
"extensions": [
  "existing-extension-id",
  "new-extension-id"
]
```

### Adding Python Dependencies

Add to `pyproject.toml` and rebuild:

```toml
[dependency-groups]
dev = [
    # ... existing deps
    "new-package>=version",
]
```

## References

- [Dev Container Specification](https://containers.dev/)
- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [uv Documentation](https://docs.astral.sh/uv/)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- [actionlint](https://github.com/rhysd/actionlint)
