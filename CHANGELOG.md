# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-08-12

Expanded the policy library using patterns from the HashiCorp AWS, Azure, GCP and cloud-agnostic libraries, plus Tencent Cloud/CIS security guidance.

### Added

- CAM wildcard policy-action control and access-key age control
- COS public-access, bucket-policy, versioning and logging controls
- CDB audit logging, backup retention and deletion protection controls
- CLB HTTPS and deletion-protection controls
- CVM image-source control
- Security-group egress control
- KMS key-rotation control
- Provider version-constraint control
- Generic protected-resource destruction control
- Pass/fail fixtures for all policies

### Changed

- Reworked `restrict-cos-acl` to also detect public bucket-policy principals
- Parameterized TKE minimum Kubernetes version and allowed network plugins
- Removed `restrict-vpc-cidr`, `validate-provider-regions` and the invalid CVM deletion policy
- Updated the bilingual README files with the complete policy matrix and design references
- Fixed tfconfig helper parsing and Sentinel 0.41.0 compatibility issues

### Validation

- 25 policies
- 50 pass/fail test cases
- Full Sentinel test suite passes with Sentinel 0.41.0

## [0.1.0] - 2026-08-11

Initial public release.

### Added

- Common helper functions for `tfplan/v2` and `tfconfig/v2` imports
- Tencent Cloud-specific helper functions
- Initial Tencent Cloud policy set and test fixtures
- Policy set configuration, bilingual documentation and CI workflow
- Contribution, security and ownership documents

[0.2.0]: https://github.com/susunola/tencentcloud-sentinel-policies/releases/tag/v0.2.0
[0.1.0]: https://github.com/susunola/tencentcloud-sentinel-policies/releases/tag/v0.1.0
