# Base image pinned by digest, not tag (OSSF Scorecard Pinned-Dependencies):
# tags are mutable aliases that can be silently repointed; a digest pins the
# exact multi-arch manifest list. Dependabot's `docker` ecosystem keeps this
# digest fresh (see .github/dependabot.yml).
#
# Equivalent tag: ghcr.io/astral-sh/uv:0.12.13-python3.13-trixie-slim
# (manifest list digest fetched from GHCR on 2026-09-11). uv 0.12.13 aligns
# with the build backend requirement in pyproject.toml
# (`uv_build>=0.12.6,<0.13.0`).
#
# The digest is inlined directly instead of being assembled from ARG values:
# Dependabot cannot update `FROM` lines whose reference is composed from ARG
# variables, which would strand this pin on a stale image.
#
# History note: the previously referenced `0.8.6-python3.13-trixie-slim` tag
# does not exist on GHCR (uv images only switched from bookworm to trixie in
# 0.8.11+), so builds could never have resolved it; the digest pin replaces
# both the broken tag and the mutable-tag risk in one change.
FROM ghcr.io/astral-sh/uv@sha256:c0ba49559fc5622531fd05a5747b52afb49ffa883574bbf8eb719ebd103efb84

# Prevent cross-filesystem warnings and enable bytecode compilation
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/workspaces/.venv \
    DEBIAN_FRONTEND=noninteractive

# Set working directory - VS Code mounts workspace here
WORKDIR /workspaces

# Install additional system packages if needed (git is already in base image)
# Add any other system dependencies here as needed
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/root/.cache/uv \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    # Common development tools
    vim-tiny \
    # Ripgrep - fast code search tool (used for searching codebases)
    ripgrep \
    curl \
    # Clean up to reduce image size
    && rm -rf /var/lib/apt/lists/*

# Switch to non-root user for security (optional, uncomment if needed)
# The base uv image runs as root by default
# USER vscode
