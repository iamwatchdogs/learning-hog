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
# Pinned to actionlint 1.7.12 release artifacts with SHA256 verification.
# This avoids the `bash <(curl ...)` / `curl | bash` download-then-run pattern
# flagged by OSSF Scorecard Pinned-Dependencies (use a file download, verify
# the hash, then extract locally instead of executing remote code).
# Checksums from https://github.com/rhysd/actionlint/releases/download/v1.7.12/actionlint_1.7.12_checksums.txt
ACTIONLINT_VERSION="1.7.12"
ACTIONLINT_TMPDIR="$(mktemp -d)"
# EXIT fires on all shell exits (success, `set -e` failure, INT/TERM), so the
# temp dir is removed even if curl/sha256sum/tar/install fails midway. Single
# EXIT trap only — adding INT/TERM alongside would run cleanup twice.
trap 'rm -rf -- "${ACTIONLINT_TMPDIR:-}"' EXIT
case "$(uname -m)" in
    x86_64) ACTIONLINT_ARCH="amd64"; ACTIONLINT_SHA256="8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8" ;;
    aarch64|arm64) ACTIONLINT_ARCH="arm64"; ACTIONLINT_SHA256="325e971b6ba9bfa504672e29be93c24981eeb1c07576d730e9f7c8805afff0c6" ;;
    *)
        echo "Unsupported architecture '$(uname -m)' for actionlint install" >&2
        exit 1
        ;;
esac
ACTIONLINT_TARBALL="${ACTIONLINT_TMPDIR}/actionlint.tar.gz"
# --fail: curl's own docs -- raw HTTP errors must exit non-zero; without it a
# 4xx/5xx body would be written to the tarball instead of failing fast.
curl --fail --location --silent --show-error \
    -o "${ACTIONLINT_TARBALL}" \
    "https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_${ACTIONLINT_ARCH}.tar.gz"
echo "${ACTIONLINT_SHA256}  ${ACTIONLINT_TARBALL}" | sha256sum --check -
tar -xzf "${ACTIONLINT_TARBALL}" -C "${ACTIONLINT_TMPDIR}" actionlint
install -m 0755 "${ACTIONLINT_TMPDIR}/actionlint" /usr/local/bin/actionlint
trap - EXIT
rm -rf -- "${ACTIONLINT_TMPDIR}"

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
