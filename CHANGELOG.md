# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-08-11

Initial public release.

### Added

- Common helper functions for `tfplan/v2` and `tfconfig/v2` imports
  (`common-functions/`)
- Tencent Cloud specific helpers: resource tag discovery, security group rule
  extraction, CIDR validation (`tencentcloud-functions/`)
- 12 Sentinel policies covering compute, storage, network, database and
  Kubernetes:
  - `restrict-cvm-instance-type` — limit CVM to approved instance types
  - `enforce-mandatory-tags` — require standard tags on key resources
  - `restrict-security-group-cidr` — block 0.0.0.0/0 on critical ports
  - `require-cos-encryption` — enforce COS server-side encryption
  - `restrict-cos-acl` — enforce private COS bucket ACL
  - `restrict-clb-access-log` — enforce CLB access logging
  - `restrict-cdb-public-access` — deny public database exposure
  - `validate-provider-regions` — restrict provider to approved regions
  - `protect-against-cvm-deletion` — require termination protection
  - `restrict-vpc-cidr` — enforce RFC 1918 CIDR ranges
  - `require-cbs-encryption` — enforce CBS disk encryption
  - `restrict-tke-cluster` — enforce VPC-CNI and minimum K8s version
- 8 test cases (pass/fail) for 4 policies with mock Terraform plan data
- Policy set configuration (`sentinel.hcl`) with enforcement levels
- Bilingual documentation: `README.md` (EN) and `README.zh-CN.md` (ZH)
- CI workflow: Sentinel fmt + test on every PR and push to main
- Contribution, security and ownership documents (`CONTRIBUTING.md`,
  `SECURITY.md`, `CODEOWNERS`)
- Editor configuration (`.editorconfig`)

[0.1.0]: https://github.com/susunola/tencentcloud-sentinel-policies/releases/tag/v0.1.0
