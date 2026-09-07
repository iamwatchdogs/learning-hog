ARG UV_VERSION=0.8.6
ARG PYTHON_VERSION=3.13

FROM ghcr.io/astral-sh/uv:${UV_VERSION}-python${PYTHON_VERSION}-trixie-slim

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
