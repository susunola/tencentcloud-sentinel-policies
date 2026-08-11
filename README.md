# Tencent Cloud Sentinel Policies

[![License](https://img.shields.io/badge/license-MPL--2.0-blue.svg)](LICENSE)

HashiCorp Sentinel policies for Tencent Cloud infrastructure governance. These policies enforce security, compliance, and operational best practices for resources managed by the [TencentCloud Terraform Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud).

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
|--------|------------|-------------|
| `restrict-cvm-instance-type` | advisory | Limit CVM instances to approved instance types |
| `enforce-mandatory-tags` | advisory | Require Owner, Environment, CostCenter tags on all resources |
| `restrict-security-group-cidr` | **hard-mandatory** | Block 0.0.0.0/0 on SSH, RDP, MySQL, Redis, MongoDB ports |
| `require-cos-encryption` | advisory | All COS buckets must have server-side encryption |
| `restrict-cos-acl` | **hard-mandatory** | COS bucket ACL must be "private" |
| `restrict-clb-access-log` | advisory | CLB instances must enable access logging |
| `restrict-cdb-public-access` | **hard-mandatory** | Database instances must not have public internet access |
| `validate-provider-regions` | advisory | TencentCloud providers restricted to approved regions |
| `protect-against-cvm-deletion` | advisory | Production CVM instances must enable termination protection |
| `restrict-vpc-cidr` | advisory | VPC CIDR blocks must use RFC 1918 private ranges |
| `require-cbs-encryption` | advisory | All CBS disks must be encrypted at rest |
| `restrict-tke-cluster` | advisory | TKE clusters must meet minimum version and network requirements |

## Quick Start

### Prerequisites

- [Sentinel CLI](https://developer.hashicorp.com/sentinel/downloads) >= 0.26.0
- Terraform >= 1.0 with [TencentCloud Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud)

### Local Testing

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

Each policy has `param` blocks that can be overridden:

- `restrict-cvm-instance-type` — `allowed_types` (list of instance type IDs)
- `enforce-mandatory-tags` — `resource_types`, `mandatory_tags`
- `restrict-security-group-cidr` — `forbidden_ports`, `unrestricted_cidrs`
- `validate-provider-regions` — `allowed_regions`
- `restrict-tke-cluster` — `min_kubernetes_version`, `allowed_network_types`
- `protect-against-cvm-deletion` — `protected_tag_key`, `protected_tag_value`

## Contributing

1. Fork the repository
2. Add or modify policies following the existing patterns
3. Add `pass.hcl` and `fail-*.hcl` test cases with mock data
4. Run `sentinel test` to verify
5. Submit a pull request

Policy naming convention: `verb-noun[-qualifier]` (e.g., `restrict-cvm-instance-type`, `require-cos-encryption`).

## Relationship to Official Repo

This repository follows the same structure and conventions as [hashicorp/terraform-sentinel-policies](https://github.com/hashicorp/terraform-sentinel-policies). The `common-functions/` modules are derived from that repository. The `tencentcloud/` directory is the Tencent Cloud equivalent of the AWS/Azure/GCP directories in the official repo.

## License

MPL-2.0 — see [LICENSE](LICENSE) for details.
