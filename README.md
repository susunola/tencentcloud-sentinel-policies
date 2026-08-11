<p align="center">
  <b>English</b> &nbsp;|&nbsp;
  <a href="README.zh-CN.md">简体中文</a>
</p>

# Tencent Cloud Sentinel Policies

[![License](https://img.shields.io/badge/license-MPL--2.0-blue.svg)](LICENSE)
[![Sentinel](https://img.shields.io/badge/sentinel-%3E%3D0.26.0-844FBA)](https://developer.hashicorp.com/sentinel/downloads)

HashiCorp Sentinel policies for Tencent Cloud infrastructure governance — enforce security, compliance, and operational best practices for resources managed by the [TencentCloud Terraform Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud).

## Approach

These policies use **Route A** (built-in imports) — no custom Sentinel plugin required. All data comes from the `tfplan/v2` and `tfconfig/v2` imports that ship with Terraform Cloud/Enterprise. The `common-functions/` helpers wrap these imports so policy authors write readable, intent-driven rules instead of raw data traversal.

```
Policy (restrict-cvm-instance-type.sentinel)
  │
  ├── import "tfplan-functions" as plan
  │     └── common-functions/tfplan-functions/
  │           └── wrap tfplan/v2 (built-in, no plugin)
  │
  └── import "tencentcloud-functions" as tc
        └── tencentcloud/tencentcloud-functions/
              └── Tencent Cloud resource discovery helpers
```

## Structure

```
tencentcloud-sentinel-policies/
├── common-functions/           # Reusable Sentinel modules
│   ├── tfplan-functions/       # tfplan/v2 import helpers
│   └── tfconfig-functions/     # tfconfig/v2 import helpers
├── tencentcloud/               # Tencent Cloud policy set
│   ├── sentinel.hcl            # Policy set configuration
│   ├── tencentcloud-functions/ # Tencent Cloud specific helpers
│   │   └── tencentcloud-functions.sentinel
│   ├── *.sentinel              # Individual policy files
│   └── test/                   # Test cases (pass/fail mocks)
└── README.md
```

## Policies

| Policy | Enforcement | Description |
|---|---|---|
| `restrict-cvm-instance-type` | advisory | Limit CVM instances to approved instance types |
| `enforce-mandatory-tags` | advisory | Require Owner, Environment, CostCenter, ManagedBy tags |
| `restrict-security-group-cidr` | **hard-mandatory** | Block 0.0.0.0/0 on SSH(22), RDP(3389), MySQL(3306), Redis(6379), MongoDB(27017), PostgreSQL(5432) |
| `require-cos-encryption` | advisory | All COS buckets must have server-side encryption |
| `restrict-cos-acl` | **hard-mandatory** | COS bucket ACL must be "private" |
| `restrict-clb-access-log` | advisory | CLB instances must enable access logging |
| `restrict-cdb-public-access` | **hard-mandatory** | Database instances must not have public internet access |
| `validate-provider-regions` | advisory | TencentCloud providers restricted to approved regions |
| `protect-against-cvm-deletion` | advisory | Production CVM instances must enable termination protection |
| `restrict-vpc-cidr` | advisory | VPC CIDR blocks must use RFC 1918 private ranges |
| `require-cbs-encryption` | advisory | All CBS disks must be encrypted at rest |
| `restrict-tke-cluster` | advisory | TKE clusters must use VPC-CNI, meet minimum version and allowed network plugins |

## Test Results

```
PASS - restrict-cvm-instance-type.sentinel
  PASS - test/restrict-cvm-instance-type/fail.hcl    # disallowed instance type → violation ✓
  PASS - test/restrict-cvm-instance-type/pass.hcl    # allowed types → no violation ✓

PASS - restrict-security-group-cidr.sentinel
  PASS - test/restrict-security-group-cidr/fail.hcl  # SSH open to 0.0.0.0/0 → violation ✓
  PASS - test/restrict-security-group-cidr/pass.hcl  # internal CIDR only → clean ✓

PASS - enforce-mandatory-tags.sentinel
  PASS - test/enforce-mandatory-tags/fail-missing-tags.hcl  # missing tags → violation ✓
  PASS - test/enforce-mandatory-tags/pass.hcl               # all tags present → clean ✓

PASS - require-cos-encryption.sentinel
  PASS - test/require-cos-encryption/fail.hcl  # no encryption → violation ✓
  PASS - test/require-cos-encryption/pass.hcl  # SSE-COS enabled → clean ✓
```

### Test Layer

Each policy has its own test directory with pass/fail scenarios:

```
test/<policy>/
├── pass.hcl                          # Test config: expects main = true
├── fail[-scenario].hcl               # Test config: expects main = false
├── mock-tfplan-pass.sentinel         # Mock Terraform plan (compliant resources)
└── mock-tfplan-fail[-scenario].sentinel  # Mock plan (non-compliant resources)
```

Test mock data simulates real Terraform plans — the same `tfplan/v2` import structure you would see from `terraform show -json`.

## Prerequisites

- [Sentinel CLI](https://developer.hashicorp.com/sentinel/downloads) >= 0.26.0
- Terraform >= 1.0 with [TencentCloud Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud)

## Quick Start

```bash
# Install Sentinel CLI
brew install hashicorp/tap/sentinel

# Run all policy tests
cd tencentcloud
sentinel test -verbose

# Test a single policy
sentinel test restrict-cvm-instance-type -verbose
```

### Usage in Terraform Cloud / Enterprise

1. Add this repository as a Policy Set in your TFC/TFE organization
2. Set enforcement levels per policy (defaults are advisory — adjust in `sentinel.hcl`)
3. Attach the policy set to workspaces using the TencentCloud provider

To customize parameters, override them in your policy set configuration:

```hcl
# Override allowed instance types for your organization
policy "restrict-cvm-instance-type" {
  source            = "./tencentcloud/restrict-cvm-instance-type.sentinel"
  enforcement_level = "hard-mandatory"
  params = {
    allowed_types = ["S5.LARGE8", "S5.2XLARGE16", "S6.LARGE16"]
  }
}
```

## Customization

Each policy exposes `param` blocks that can be overridden at the policy-set level:

| Policy | Params | Default |
|---|---|---|
| `restrict-cvm-instance-type` | `allowed_types` | S5.MEDIUM4, S5.LARGE8, S5.2XLARGE16, S5.4XLARGE32, S6.MEDIUM4, S6.LARGE8, SA2.MEDIUM4, SA2.LARGE8, SA3.MEDIUM8, SA3.LARGE16 |
| `enforce-mandatory-tags` | `resource_types`, `mandatory_tags` | CVM/COS/CLB/MySQL/VPC/CBS/TKE/Redis; Owner, Environment, CostCenter, ManagedBy |
| `restrict-security-group-cidr` | `forbidden_ports`, `unrestricted_cidrs` | [22, 3389, 3306, 6379, 27017, 5432]; ["0.0.0.0/0", "::/0"] |
| `validate-provider-regions` | `allowed_regions` | ap-guangzhou, ap-shanghai, ap-beijing, ap-singapore |
| `restrict-tke-cluster` | `min_kubernetes_version`, `allowed_network_types` | 1.20; ["VPC-CNI"] |
| `protect-against-cvm-deletion` | `protected_tag_key`, `protected_tag_value` | Environment; Production |

## Relationship to Official Repo

This repository follows the same structure and conventions as [hashicorp/terraform-sentinel-policies](https://github.com/hashicorp/terraform-sentinel-policies). The `common-functions/` modules are derived from that repository. The `tencentcloud/` directory is the Tencent Cloud equivalent of the `aws/` / `azure/` / `gcp/` directories in the official repo.

## Contributing

1. Fork the repository
2. Add or modify policies following the existing patterns
3. Add `pass.hcl` and `fail-*.hcl` test cases with mock data
4. Run `sentinel test` to verify
5. Submit a pull request

Policy naming convention: `verb-noun[-qualifier]` (e.g. `restrict-cvm-instance-type`, `require-cos-encryption`).

## Notes

- These policies use Route A (built-in imports) — no custom Sentinel SDK plugin is needed.
- Sentinel reserved keywords (`rule` etc.) cannot be used as variable names.
- `sentinel test` does not read `sentinel.hcl` — module imports must be declared in each test `.hcl` file.
- Sentinel v0.41.0 requires `param "name" { value = ... }` syntax; the old `param name default value` form is deprecated.

## License

[MPL-2.0](LICENSE)
