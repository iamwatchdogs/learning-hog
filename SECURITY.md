# Security Policy

## Supported versions

Security fixes are applied to the latest `main` branch and are shipped in the
most recent tagged release. Older releases do not receive security patches;
upgrade to the latest release before reporting an issue on an older version.

## Reporting a vulnerability

Please do **not** open a public GitHub issue for security reports.

Use one of these private channels:

- GitHub private vulnerability reporting:
  <https://github.com/iamwatchdogs/learning-hog/security/advisories/new>
- Email: <shamith301102@gmail.com>

GitHub private vulnerability reporting is preferred: it keeps the report,
discussion, fix, and coordinated release in one private place.

## What to include in a report

- A description of the vulnerability and its suspected impact.
- Step-by-step instructions or a proof-of-concept to reproduce it.
- The affected version, commit SHA, or release artifact (with checksum if
  available).
- Any known workarounds or mitigations you have identified.

## What to expect

- Acknowledgement of your report within 7 days.
- An initial assessment (affected or not, severity, next steps) within 30
  days of acknowledgement.
- A coordinated fix and advisory release within 90 days for accepted
  vulnerabilities, or an agreed timeline with you for complex fixes.
- Credit in the advisory unless you prefer to remain anonymous.

## Scope

In scope:

- The `learning-hog` CLI and its release artifacts.
- The build, release, and supply-chain workflows under `.github/`.
- The development container configuration under `.devcontainer/`.

Out of scope:

- Vulnerabilities in third-party services (GitHub, PyPI, GHCR) that are not
  caused by this repository's configuration; report those upstream.
- Reports from automated scanners without a demonstration of impact.
- Denial-of-service or social-engineering attacks against maintainers.

## Disclosure policy

This project follows coordinated vulnerability disclosure as described in the
OpenSSF vulnerability disclosure guide:
<https://github.com/ossf/oss-vulnerability-guide/blob/main/maintainer-guide.md>.
Reports remain private until a fix is released, after which the advisory is
published and credited.
