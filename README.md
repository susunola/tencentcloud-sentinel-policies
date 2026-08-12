<p align="center">
  <b>English</b> &nbsp;|&nbsp;
  <a href="README.zh-CN.md">简体中文</a>
</p>

# Tencent Cloud Sentinel Policies

[![License](https://img.shields.io/badge/license-MPL--2.0-blue.svg)](LICENSE)
[![Sentinel](https://img.shields.io/badge/sentinel-%3E%3D0.41.0-844FBA)](https://developer.hashicorp.com/sentinel/downloads)
[![Tests](https://img.shields.io/badge/tests-50%20passing-brightgreen.svg)](#test-results)

HashiCorp Sentinel policies for Tencent Cloud infrastructure governance. The policies are designed for resources managed by the [TencentCloud Terraform Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud), with controls inspired by the official HashiCorp AWS, Azure, GCP and cloud-agnostic policy libraries, CIS Tencent Cloud guidance, and common cloud security practices.

> This is a community policy library, not a complete compliance certification. Review every control against your architecture, provider version, business requirements and applicable regulatory standard before enforcing it in production.

## Approach

These policies use **Route A** (built-in imports) — no custom Sentinel SDK plugin is required. Data comes from the Terraform Cloud/Enterprise `tfplan/v2` and `tfconfig/v2` imports. The reusable modules under `common-functions/` keep policy code focused on intent rather than raw import traversal.

```
Policy
  │
  ├── tfplan/v2 ── common-functions/tfplan-functions/
  │                └── resource changes and planned values
  │
  ├── tfconfig/v2 ─ common-functions/tfconfig-functions/
  │                 └── provider and configuration checks
  │
  └── tencentcloud-functions/
                     └── Tencent Cloud resource and security-group helpers
```

## Structure

```
tencentcloud-sentinel-policies/
├── common-functions/
│   ├── tfplan-functions/       # tfplan/v2 helpers
│   └── tfconfig-functions/     # tfconfig/v2 helpers
├── tencentcloud/
│   ├── sentinel.hcl            # Policy set configuration
│   ├── tencentcloud-functions/ # Tencent Cloud-specific helpers
│   ├── *.sentinel               # Policy files
│   └── test/                    # Pass/fail tests and Sentinel mocks
├── README.md
└── README.zh-CN.md
```

## Policies

### Governance and supply chain

| Policy | Enforcement | Description |
|---|---|---|
| `enforce-mandatory-tags` | advisory | Require standard ownership and cost tags on key resources |
| `require-provider-version-constraint` | advisory | Require a version constraint for the TencentCloud provider |
| `prevent-resource-destruction` | **hard-mandatory** | Block deletion of resources marked as production or Terraform-managed |

### Identity and access

| Policy | Enforcement | Description |
|---|---|---|
| `restrict-cam-policy-actions` | advisory | Block Tencent CAM allow statements with `action=*` and `resource=*` |

### Compute and Kubernetes

| Policy | Enforcement | Description |
|---|---|---|
| `restrict-cvm-instance-type` | advisory | Limit CVM instances to approved instance types |
| `restrict-cvm-image-source` | advisory | Limit CVM images to approved image-ID prefixes |
| `restrict-tke-cluster` | advisory | Require VPC networking, a minimum Kubernetes version and an approved plugin |

### Network and load balancing

| Policy | Enforcement | Description |
|---|---|---|
| `restrict-security-group-cidr` | **hard-mandatory** | Block unrestricted ingress to critical ports |
| `restrict-security-group-egress` | advisory | Block unrestricted egress to all ports or database ports |
| `restrict-clb-https` | advisory | Require CLB listeners to use HTTPS rather than plain HTTP |
| `restrict-clb-access-log` | advisory | Require CLB access logging |
| `restrict-clb-deletion-protection` | advisory | Require deletion protection on CLB instances |

### COS and storage

| Policy | Enforcement | Description |
|---|---|---|
| `restrict-cos-acl` | **hard-mandatory** | Require private COS ACLs |
| `restrict-cos-bucket-policy` | **hard-mandatory** | Reject wildcard or anonymous COS bucket-policy principals |
| `require-cos-encryption` | advisory | Require COS server-side encryption |
| `require-cos-versioning` | advisory | Require COS object versioning |
| `require-cos-logging` | advisory | Require COS access logging |
| `require-cbs-encryption` | advisory | Require CBS disk encryption at rest |

### Database and key management

| Policy | Enforcement | Description |
|---|---|---|
| `restrict-cdb-public-access` | **hard-mandatory** | Prevent public internet access to CDB instances |
| `require-cdb-audit-log` | advisory | Validate declared MySQL audit-service resources and retention |
| `require-cdb-backup-retention` | advisory | Validate declared MySQL backup-policy retention |
| `require-cdb-deletion-protection` | advisory | Prevent CDB `force_delete=true` from bypassing recycle-bin recovery |
| `require-kms-key-rotation` | advisory | Require automatic KMS key rotation |

## Test Results

The repository contains **23 policies and 48 pass/fail test cases**. The complete suite passes with Sentinel 0.41.0:

```text
23 policies PASS
48 test cases PASS
0 policy failures
```

Each policy has an isolated test directory:

```
test/<policy>/
├── pass.hcl
├── fail[-scenario].hcl
├── mock-tfplan-pass.sentinel
└── mock-tfplan-fail[-scenario].sentinel
```

The provider-version policy uses `mock-tfconfig-*.sentinel` because it evaluates the `tfconfig/v2` import. Provider attributes and resource mappings are tracked in [`docs/schema-verification.md`](docs/schema-verification.md).

## Prerequisites

- [Sentinel CLI](https://developer.hashicorp.com/sentinel/downloads) 0.41.0 or compatible
- Terraform with the [TencentCloud Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud)
- Terraform Cloud or Terraform Enterprise for policy enforcement

## Quick Start

```bash
# Install Sentinel CLI
brew install hashicorp/tap/sentinel

# Run all policy tests
cd tencentcloud
sentinel test -verbose

# Test one policy
sentinel test -run restrict-security-group-cidr -verbose
```

## Usage in Terraform Cloud / Enterprise

1. Add this repository as a Policy Set in your HCP Terraform/TFE organization.
2. Review the policy list and enforcement levels in `tencentcloud/sentinel.hcl`.
3. Attach the Policy Set to workspaces that use the TencentCloud provider.
4. Start with advisory enforcement in a non-production workspace, then promote controls after reviewing violations.
5. Customize policy parameters for your organization and keep exceptions in code review.

Example:

```hcl
policy "restrict-cvm-instance-type" {
  source            = "./tencentcloud/restrict-cvm-instance-type.sentinel"
  enforcement_level = "hard-mandatory"
  params = {
    allowed_types = ["S5.LARGE8", "S5.2XLARGE16", "S6.LARGE16"]
  }
}
```

## Key Parameters

| Policy | Parameters |
|---|---|
| `restrict-cvm-instance-type` | `allowed_types` |
| `enforce-mandatory-tags` | `resource_types`, `mandatory_tags` |
| `restrict-security-group-cidr` | `forbidden_ports`, `unrestricted_cidrs` |
| `restrict-security-group-egress` | `forbidden_ports`, `unrestricted_cidrs` |
| `restrict-cvm-image-source` | `allowed_image_prefixes` |
| `restrict-tke-cluster` | `min_kubernetes_version`, `allowed_network_types` |
| `require-cdb-backup-retention` | `min_backup_retention_days` |
| `require-cdb-audit-log` | `min_audit_log_retention_days` |
| `restrict-cam-policy-actions` | `forbidden_wildcard` |
| `require-kms-key-rotation` | none |
| `require-provider-version-constraint` | none |
| `prevent-resource-destruction` | `protected_tags` |

## Design References

The policy design draws on:

- [HashiCorp Terraform Sentinel policy examples](https://developer.hashicorp.com/terraform/cloud-docs/sentinel/examples)
- [HashiCorp Terraform operating guide for Sentinel](https://developer.hashicorp.com/validated-designs/terraform-operating-guides-standardization/policy-as-code-sentinel)
- [HashiCorp terraform-sentinel-policies](https://github.com/hashicorp/terraform-sentinel-policies)
- [CIS Tencent Cloud Benchmarks](https://www.cisecurity.org/benchmark/tencent)
- Tencent Cloud security and compliance guidance

The cross-cloud mappings are references for control intent, not claims that Tencent Cloud resources have identical semantics to AWS, Azure or GCP resources.

## Contributing

1. Fork the repository.
2. Add or modify a policy following the existing naming and import patterns.
3. Add both compliant and non-compliant tests with minimal mocks.
4. Run `sentinel fmt` and `sentinel test -verbose`.
5. Submit a pull request with the provider version and resource schema used.

Policy naming convention: `verb-noun[-qualifier]`, for example `restrict-cvm-instance-type` and `require-cos-encryption`.

## Notes

- Route A uses built-in Sentinel imports; no custom Sentinel SDK plugin is needed.
- Sentinel reserved keywords such as `rule` cannot be used as variable names.
- `sentinel test` requires module imports in each test `.hcl`; it does not use the policy-set module declarations as test fixtures.
- Review provider schemas before enabling hard-mandatory policies. Terraform provider attributes can change across versions.

## License

[MPL-2.0](LICENSE)
