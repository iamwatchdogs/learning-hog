# Base image pinned as tag@digest (OSSF Scorecard Pinned-Dependencies):
# tags alone are mutable aliases that can be silently repointed, so the
# digest pins the exact multi-arch manifest list; the tag stays alongside
# the digest so the human-readable version is visible in the FROM line and
# Dependabot updates both together (see .github/dependabot.yml).
#
# Digest: ghcr.io/astral-sh/uv@sha256:62f8c047d0a0e9ece6b53fc63df902585a67a47a7f318ddec4a37db586edc8e3
# (manifest list fetched from GHCR on 2026-09-11). Tag
# 0.12.13-python3.13-trixie-slim aligns with the build backend requirement
# in pyproject.toml (`uv_build>=0.12.6,<0.13.0`).
#
# The digest is inlined directly instead of being assembled from ARG values:
# Dependabot cannot update `FROM` lines whose reference is composed from ARG
# variables, which would strand this pin on a stale image.
#
# History note: the previously referenced `0.8.6-python3.13-trixie-slim` tag
# does not exist on GHCR (uv images only switched from bookworm to trixie in
# 0.8.11+), so builds could never have resolved it; the digest pin replaces
# both the broken tag and the mutable-tag risk in one change.
FROM ghcr.io/astral-sh/uv:0.12.19-python3.13-trixie-slim@sha256:aba5f865793af9275ceaa06d30935dfc6db8b81969c9fb099b0ebca6396b189e

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
