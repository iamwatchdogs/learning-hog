#!/bin/bash
set -e

echo "🐍 Setting up learning-hog dev environment..."

# Ensure uv cache directory exists with proper permissions
if [ -d "/workspaces/.uv_cache" ]; then
    rm -rf /workspaces/.uv_cache
fi
mkdir -p /workspaces/.uv_cache

# Install actionlint (GitHub Actions workflow linter) into /usr/local/bin.
# The `jimeh.actionlint` VS Code extension needs it on PATH; `prek run` uses
# the prek-managed copy, so this is for editor feedback and manual runs.
echo "⚙️ Installing actionlint..."
# Installer URL pinned to a reviewed commit of rhysd/actionlint main
# (011a6d15e749bb3f2d771eed9c7aa0e7e3e10ee7) so the post-create step never
# executes mutable branch source; the script itself downloads the pinned
# release 1.7.12.
# --fail: curl's own docs -- raw HTTP errors must exit non-zero; without it a
# 4xx/5xx body would be piped into bash (and process substitution runs
# asynchronously, so `set -e` cannot catch curl failures).
bash <(curl --fail --location --silent --show-error https://raw.githubusercontent.com/rhysd/actionlint/011a6d15e749bb3f2d771eed9c7aa0e7e3e10ee7/scripts/download-actionlint.bash) 1.7.12 /usr/local/bin

# Install prek (pre-commit runner) - used for running pre-commit hooks
# The project uses prek in CI via j178/prek-action
echo "🔧 Installing prek..."
uv tool install prek

# Sync project dependencies (locked, all groups including dev)
echo "📦 Installing dependencies with uv sync..."
uv sync --locked --all-groups

# Verify the installation
echo "✅ Verifying installation..."
uv run python --version
uv run ruff --version
uv run ty --version
uv run pytest --version
prek --version
actionlint -version | head -n1
rg --version

# Display installed tools
echo ""
echo "📋 Dev environment ready!"
echo "   Python: $(uv run python --version)"
echo "   Ruff: $(uv run ruff --version)"
echo "   Ty: $(uv run ty --version)"
echo "   Pytest: $(uv run pytest --version)"
echo "   Prek: $(prek --version)"
echo "   Actionlint: $(actionlint -version | head -n1)"
echo "   Ripgrep: $(rg --version | head -n1)"
echo ""
echo "🚀 Usage:"
echo "   uv run python src/learning_hog/main.py --help"
echo "   uv run pytest"
echo "   uv run ruff check src tests"
echo "   uv run ty check src"
echo "   prek run --all-files  # Run pre-commit hooks"
echo "   actionlint            # Lint GitHub Actions workflows"
echo "   rg 'pattern' src/     # Search code with ripgrep"
echo ""
echo "💡 Tip: Run 'uv sync' to update dependencies after pulling changes"
