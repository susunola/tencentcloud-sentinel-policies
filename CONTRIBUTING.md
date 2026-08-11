# Contributing

Thanks for your interest in improving this policy library. This document
describes the conventions that keep the repository consistent.

## Design Principles

1. **Route A only — no custom plugins.** Every policy must use only the
   built-in `tfplan/v2` and `tfconfig/v2` imports. No external data sources,
   no custom Sentinel SDK plugins.
2. **Parametrised, not hardcoded.** All thresholds, lists and identifiers
   must be exposed as `param` blocks so they can be overridden at the
   policy-set level without modifying policy source.
3. **Test before commit.** Every policy must have at least one `pass.hcl`
   and one `fail.hcl` test case. Tests must reproduce cleanly with
   `sentinel test`.
4. **Composable helpers.** Domain-specific logic (resource discovery,
   tag validation, CIDR checks) belongs in `common-functions/` or
   `tencentcloud-functions/` — policy files should read like rules, not
   like data queries.

## Development Workflow

```bash
make test          # sentinel test -verbose
make fmt           # sentinel fmt
```

Before opening a pull request:

- `sentinel fmt -check` passes
- `sentinel test -verbose` passes
- README.md (EN) and README.zh-CN.md (ZH) are updated together

## Policy Naming Convention

Policies follow `verb-noun[-qualifier]`:

```
restrict-cvm-instance-type
enforce-mandatory-tags
require-cos-encryption
validate-provider-regions
protect-against-cvm-deletion
```

## Adding a New Policy

1. Create `<policy-name>.sentinel` in `tencentcloud/`
2. Import `tfplan-functions` and/or `tencentcloud-functions` as needed
3. Expose configurable thresholds as `param` blocks
4. Add an entry to `tencentcloud/sentinel.hcl`
5. Create `test/<policy-name>/` with `pass.hcl`, `fail.hcl`, and mock data
6. Run `make test` and ensure all pass
7. Update the policy table in both README files

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(policy): add restrict-tke-node-security-group
fix(test): correct mock port type in security-group test
docs: update param table in README
```

Common scopes: `policy`, `common-functions`, `tencentcloud-functions`,
`test`, `ci`, `docs`.

## Language Policy

All code, comments, commit messages and tooling output are in **English**.
The Chinese narrative documentation lives in `README.zh-CN.md` and must be
kept in sync with `README.md`.

## Versioning

Releases follow SemVer. The current version lives in the `VERSION` file and
changes are recorded in `CHANGELOG.md` (Keep a Changelog format).
