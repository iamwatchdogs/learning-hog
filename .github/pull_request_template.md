# Summary

<!-- A concise description of the changes proposed in this pull request, and
     why they are needed. If a spec or plan document exists for this work
     (e.g. docs/specs/<name>.md), link it here. -->

## Related issues

<!-- Link the issue this pull request addresses, e.g. "Fixes #123".
     If there is no related issue, explain why one was not opened. -->

Fixes #

## Changes

<!-- List the notable changes in this pull request. -->

-

## Verification

<!-- Show the evidence, not an assertion. Paste the actual output of the
     commands you ran (the template below is the project's standard loop). -->

```bash
uv run ruff check src tests
uv run ruff format --check src tests
uv run ty check src
uv run pytest
```

## Verification output

<!-- Paste the actual output of each command below. Evidence, not assertions:
     a green checkmark without output is not verification. -->

```text

```

## AI assistance disclosure

<!-- Required, per the project's AI policy in CONTRIBUTING.md. State the
     tool(s) used and the extent of assistance. Disclosure is mandatory, but
     AI-assisted contributions are welcome. -->

- **Tools used:**
- **Extent:**

## Human understanding attestation

<!-- If you cannot explain every change here without AI assistance, ask
     questions in the PR instead of merging. -->

- [ ] I can explain what every change in this pull request does and why it was
      made.

## Agent contribution checklist

<!-- For agent-authored or agent-assisted PRs: the agent must leave evidence
     of a closed verification loop, and a human must review substance, not
     structure. Watch for taxidermy tests (well-formed tests that assert
     nothing) and symptom patches (consumers tolerating bad data instead of
     fixing the producer). -->

- [ ] Tests fail before the fix and pass after (red/green shown in the output
      above), or the change is genuinely untestable and the reason is stated
- [ ] Tests assert specific expected values, not just that code runs
- [ ] The change fixes the cause, not the symptom (where the contract broke,
      not wherever the crash surfaced)
- [ ] Scope stayed small: one logical change, no speculative abstractions or
      unrelated refactors

## Checklist

<!-- The local checks are described in CONTRIBUTING.md. -->

- [ ] I have read and followed the
      [contributing guidelines](CONTRIBUTING.md)
- [ ] This pull request follows the
      [Code of Conduct](CODE_OF_CONDUCT.md)
- [ ] `uv run ruff check src tests` and `uv run ruff format src tests` pass
- [ ] `uv run ty check src` passes
- [ ] `uv run pytest` passes
- [ ] Documentation and/or tests were updated where applicable
