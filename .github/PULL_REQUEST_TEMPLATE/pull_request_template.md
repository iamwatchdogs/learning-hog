# Summary

<!-- A concise description of the changes proposed in this pull request, and
     why they are needed. -->

## Related issues

<!-- Link the issue this pull request addresses, e.g. "Fixes #123".
     If there is no related issue, explain why one was not opened. -->

Fixes #

## Changes

<!-- List the notable changes in this pull request. -->

-

## Type of change

<!-- Check the option that best fits. Mark the first box if none do. -->

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would break existing functionality)
- [ ] Documentation update
- [ ] Refactor or code health (no behavior change)
- [ ] Build, CI, or developer tooling

## Verification

<!-- The local checks are described in CONTRIBUTING.md. Adjust the list to
     what your change touches: for a docs-only change, linting the markdown
     (prek run markdownlint-cli2 --all-files) is enough. -->

```bash
uv run ruff check src tests
uv run ruff format --check src tests
uv run ty check src
uv run pytest
```

## AI assistance (optional)

<!-- Voluntary disclosure for typical contributions. If you used AI
     assistance beyond trivial editor completion, you are welcome to note the
     tool and the extent here. Review and understand everything you submit. -->

## Checklist

- [ ] I have read and followed the
      [contributing guidelines](CONTRIBUTING.md)
- [ ] This pull request follows the
      [Code of Conduct](CODE_OF_CONDUCT.md)
- [ ] `uv run ruff check src tests` and `uv run ruff format src tests` pass
- [ ] `uv run ty check src` passes
- [ ] `uv run pytest` passes
- [ ] Documentation and/or tests were updated where applicable
