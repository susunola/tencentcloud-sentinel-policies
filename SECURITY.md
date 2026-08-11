# Security Policy

## Supported Versions

Only the latest release line receives security fixes.

| Version | Supported |
|---|---|
| latest release | ✅ |
| older releases | ❌ |

## Reporting a Vulnerability

**Please do not open a public issue for security vulnerabilities.**

Report vulnerabilities privately via
[GitHub Security Advisories](https://github.com/susunola/tencentcloud-sentinel-policies/security/advisories/new).

Please include:

- the affected version (contents of the `VERSION` file or release tag)
- a description of the issue and its impact
- the affected policy file(s)
- reproduction steps, if available

You can expect an acknowledgment within 3 business days.

## Scope Notes

This repository contains HashiCorp Sentinel policies — it is purely
policy-as-code and does not run any infrastructure or handle credentials.
Reported issues are typically logic flaws in policy rules that could lead
to false negatives (missed violations) or false positives (incorrect
blocks).
