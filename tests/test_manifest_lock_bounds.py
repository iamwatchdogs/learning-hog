"""Fail when a direct dep's lower-bound major.minor drifts from uv.lock.

Dependabot's uv updater often only rewrites uv.lock while pyproject.toml
keeps a stale `>=X.Y.Z` (PR #20, PR #27). `versioning-strategy: increase`
does not reliably close that gap for this package (not on PyPI; library
misclassification in dependabot-core). This gate makes the drift visible.
"""

from __future__ import annotations

import re
import tomllib
from pathlib import Path
from typing import Any
from typing import cast

ROOT = Path(__file__).resolve().parents[1]


def _load_pyproject() -> dict[str, Any]:
    with (ROOT / "pyproject.toml").open("rb") as fh:
        return tomllib.load(fh)


def _lock_versions() -> dict[str, str]:
    text = (ROOT / "uv.lock").read_text(encoding="utf-8")
    return dict(
        re.findall(
            r'\[\[package\]\]\s*name = "([^"]+)"\s*version = "([^"]+)"',
            text,
        )
    )


def _direct_requirements(pyproject: dict[str, Any]) -> list[str]:
    project = pyproject.get("project")
    deps: list[str] = []
    if isinstance(project, dict):
        project_deps = project.get("dependencies", [])
        if isinstance(project_deps, list):
            deps.extend(item for item in project_deps if isinstance(item, str))
    groups = pyproject.get("dependency-groups")
    if isinstance(groups, dict):
        for group in groups.values():
            if isinstance(group, list):
                deps.extend(item for item in group if isinstance(item, str))
    return deps


def _requirement_name(req: str) -> str:
    match = re.match(r"([A-Za-z0-9][A-Za-z0-9._-]*)", req.strip())
    if match is None:
        msg = f"unparseable requirement: {req!r}"
        raise AssertionError(msg)
    return cast("str", match.group(1))


def _lower_bound_major_minor(req: str) -> tuple[int, int] | None:
    match = re.search(r">=\s*(\d+)\.(\d+)", req)
    if not match:
        match = re.search(r"==\s*(\d+)\.(\d+)", req)
    if not match:
        return None
    return int(match.group(1)), int(match.group(2))


def _major_minor(version: str) -> tuple[int, int]:
    parts = version.split(".")
    major = int(parts[0])
    minor = int(parts[1]) if len(parts) > 1 else 0
    return major, minor


def test_direct_dependency_bounds_match_lock_major_minor() -> None:
    pyproject = _load_pyproject()
    lock = _lock_versions()
    lock_by_norm = {name.lower().replace("_", "-"): ver for name, ver in lock.items()}
    drifts: list[str] = []

    for req in _direct_requirements(pyproject):
        name = _requirement_name(req)
        key = name.lower().replace("_", "-")
        locked = lock_by_norm.get(key)
        if locked is None:
            msg = f"{name}: present in pyproject.toml but missing from uv.lock"
            raise AssertionError(msg)

        bound = _lower_bound_major_minor(req)
        if bound is None:
            msg = (
                f"{name}: expected a >=X.Y (or ==X.Y) lower bound so "
                f"major.minor can be checked, got {req!r}"
            )
            raise AssertionError(msg)

        locked_mm = _major_minor(locked)
        if bound != locked_mm:
            drifts.append(
                f"{name}: pyproject>={bound[0]}.{bound[1]}.0 vs uv.lock {locked} "
                f"(major.minor {locked_mm[0]}.{locked_mm[1]})"
            )

    if drifts:
        msg = (
            "Direct dependency lower bounds must match uv.lock major.minor "
            "(versioning-strategy: increase intent):\n  " + "\n  ".join(drifts)
        )
        raise AssertionError(msg)
