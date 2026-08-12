# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-08-12

Corrected policy semantics against the Tencent Cloud Terraform Provider schema.

### Changed

- Replaced the invalid MySQL instance audit attribute with the separate `tencentcloud_mysql_audit_service` resource.
- Replaced the invalid MySQL backup attribute with `tencentcloud_mysql_backup_policy.retention_period`.
- Replaced the nonexistent CDB deletion-protection flag with a control that blocks `force_delete=true`.
- Replaced CLB `deletion_protection` with the provider's actual `delete_protect` attribute.
- Replaced COS `versioning_enabled` with `versioning_enable` and support for `tencentcloud_cos_bucket_version.status = "Enabled"`.
- Replaced COS `log_set_id` with `log_enable` and `log_target_bucket`.
- Rewrote CAM policy parsing for Tencent Cloud's lower-case `statement`, `effect`, `action`, and `resource` JSON schema.
- Added Tencent Cloud security-group port parsing for strings, comma-separated ports, ranges, and `all`.
- Security-group controls now inspect `action = "ACCEPT"`, avoiding false positives for DROP rules.
- Removed `restrict-cam-access-key-age`; the provider exposes no creation timestamp in the plan.
- Removed `restrict-cos-public-access`; Tencent Cloud COS has no AWS-style `public_access_block` argument.

### Added

- `docs/schema-verification.md`, documenting verified resources, attributes, types, provider version and source paths.
- Test fixtures using the real Tencent Cloud attribute names and types.

### Validation

- 23 policies
- 48 pass/fail test cases
- Sentinel formatting and full Sentinel test suite pass with Sentinel 0.41.0

## [0.2.0] - 2026-08-12

Expanded the policy library using patterns from the HashiCorp AWS, Azure, GCP and cloud-agnostic libraries, plus Tencent Cloud/CIS security guidance.

## [0.1.0] - 2026-08-11

Initial public release.

[0.3.0]: https://github.com/susunola/tencentcloud-sentinel-policies/releases/tag/v0.3.0
[0.2.0]: https://github.com/susunola/tencentcloud-sentinel-policies/releases/tag/v0.2.0
[0.1.0]: https://github.com/susunola/tencentcloud-sentinel-policies/releases/tag/v0.1.0
