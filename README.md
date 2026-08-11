# Tencent Cloud Sentinel Policies · 腾讯云 Sentinel 策略库

[![License](https://img.shields.io/badge/license-MPL--2.0-blue.svg)](LICENSE)
[![Sentinel](https://img.shields.io/badge/sentinel-%3E%3D0.26.0-844FBA)](https://developer.hashicorp.com/sentinel/downloads)

HashiCorp Sentinel policies for Tencent Cloud infrastructure governance — enforce security, compliance, and operational best practices for resources managed by the [TencentCloud Terraform Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud).

适用于腾讯云基础设施治理的 HashiCorp Sentinel 策略库——为 [TencentCloud Terraform Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud) 管理的资源强制实施安全、合规与运维最佳实践。

---

## Structure · 目录结构

```
tencentcloud-sentinel-policies/
├── common-functions/           # Reusable Sentinel modules / 可复用 Sentinel 模块
│   ├── tfplan-functions/       # tfplan/v2 import helpers
│   └── tfconfig-functions/     # tfconfig/v2 import helpers
├── tencentcloud/               # Tencent Cloud policy set / 腾讯云策略集
│   ├── sentinel.hcl            # Policy set configuration / 策略集配置
│   ├── tencentcloud-functions/ # Tencent Cloud specific helpers / 腾讯云专用辅助函数
│   │   └── tencentcloud-functions.sentinel
│   ├── *.sentinel              # Individual policy files / 各策略文件
│   └── test/                   # Test cases (pass/fail mocks) / 测试用例
└── README.md
```

## Policies · 策略清单

| Policy · 策略 | Enforcement · 级别 | Description · 说明 |
|---|---|---|
| `restrict-cvm-instance-type` | advisory | Limit CVM instances to approved instance types · 限制 CVM 仅使用指定机型 |
| `enforce-mandatory-tags` | advisory | Require Owner, Environment, CostCenter, ManagedBy tags · 强制 Owner/Environment/CostCenter/ManagedBy 标签 |
| `restrict-security-group-cidr` | **hard-mandatory** | Block 0.0.0.0/0 on SSH(22), RDP(3389), MySQL(3306), Redis(6379), MongoDB(27017), PostgreSQL(5432) · 禁止关键端口对全网开放 |
| `require-cos-encryption` | advisory | All COS buckets must have server-side encryption · COS 存储桶必须开启服务端加密 |
| `restrict-cos-acl` | **hard-mandatory** | COS bucket ACL must be "private" · COS 存储桶 ACL 必须为 private |
| `restrict-clb-access-log` | advisory | CLB instances must enable access logging · CLB 实例必须开启访问日志 |
| `restrict-cdb-public-access` | **hard-mandatory** | Database instances must not have public internet access · 数据库实例禁止公网访问 |
| `validate-provider-regions` | advisory | TencentCloud providers restricted to approved regions · 限制腾讯云 Provider 仅允许指定区域 |
| `protect-against-cvm-deletion` | advisory | Production CVM instances must enable termination protection · 生产 CVM 实例必须开启销毁保护 |
| `restrict-vpc-cidr` | advisory | VPC CIDR blocks must use RFC 1918 private ranges · VPC CIDR 必须使用 RFC 1918 私有地址段 |
| `require-cbs-encryption` | advisory | All CBS disks must be encrypted at rest · CBS 云硬盘必须加密 |
| `restrict-tke-cluster` | advisory | TKE clusters must use VPC-CNI, meet minimum version and allowed network plugins · TKE 集群强制 VPC 网络模式及最低版本要求 |

---

## Quick Start · 快速开始

### Prerequisites · 前置条件

- [Sentinel CLI](https://developer.hashicorp.com/sentinel/downloads) >= 0.26.0
- Terraform >= 1.0 with [TencentCloud Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud)

### Local Testing · 本地测试

```bash
# Install Sentinel CLI · 安装 Sentinel CLI
brew install hashicorp/tap/sentinel

# Run all policy tests · 运行全部测试
cd tencentcloud
sentinel test -verbose

# Test a single policy · 测试单个策略
sentinel test restrict-cvm-instance-type -verbose
```

### Test Results · 测试结果

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

### Usage in Terraform Cloud / Enterprise · 在 TFC/TFE 中使用

1. Add this repository as a Policy Set in your TFC/TFE organization
2. Set enforcement levels per policy (defaults are advisory — adjust in `sentinel.hcl`)
3. Attach the policy set to workspaces using the TencentCloud provider

---

1. 在 TFC/TFE 组织中添加此仓库为策略集
2. 按需调整各策略的强制级别（默认 advisory，可在 `sentinel.hcl` 中修改）
3. 将策略集绑定到使用 TencentCloud Provider 的工作区

To customize parameters, override them in your policy set configuration · 在策略集配置中覆盖参数：

```hcl
# Override allowed instance types for your organization · 按组织需求覆盖允许的机型
policy "restrict-cvm-instance-type" {
  source            = "./tencentcloud/restrict-cvm-instance-type.sentinel"
  enforcement_level = "hard-mandatory"
  params = {
    allowed_types = ["S5.LARGE8", "S5.2XLARGE16", "S6.LARGE16"]
  }
}
```

---

## Customization · 参数自定义

Each policy exposes `param` blocks that can be overridden at the policy-set level · 每个策略提供可覆盖的参数：

| Policy | Params | Default |
|---|---|---|
| `restrict-cvm-instance-type` | `allowed_types` | S5.MEDIUM4, S5.LARGE8, S5.2XLARGE16, S5.4XLARGE32, S6.MEDIUM4, S6.LARGE8, SA2.MEDIUM4, SA2.LARGE8, SA3.MEDIUM8, SA3.LARGE16 |
| `enforce-mandatory-tags` | `resource_types`, `mandatory_tags` | CVM/COS/CLB/MySQL/VPC/CBS/TKE/Redis; Owner, Environment, CostCenter, ManagedBy |
| `restrict-security-group-cidr` | `forbidden_ports`, `unrestricted_cidrs` | [22, 3389, 3306, 6379, 27017, 5432]; ["0.0.0.0/0", "::/0"] |
| `validate-provider-regions` | `allowed_regions` | ap-guangzhou, ap-shanghai, ap-beijing, ap-singapore |
| `restrict-tke-cluster` | `min_kubernetes_version`, `allowed_network_types` | 1.20; ["VPC-CNI"] |
| `protect-against-cvm-deletion` | `protected_tag_key`, `protected_tag_value` | Environment; Production |

---

## Architecture · 架构

### Route A — Built-in Imports · 路线 A — 内置导入

These policies use **Route A**: no custom Sentinel plugin required. All data comes from the built-in `tfplan/v2` and `tfconfig/v2` imports that ship with Terraform Cloud/Enterprise. The `common-functions/` helpers wrap these imports so policy authors write readable, intent-driven rules instead of raw data traversal.

本策略库使用**路线 A**：无需编写自定义 Sentinel 插件。所有数据来自 Terraform Cloud/Enterprise 内置的 `tfplan/v2` 和 `tfconfig/v2` 导入。`common-functions/` 辅助模块封装了这些导入，策略作者只需编写可读的、面向意图的规则，而非原始数据遍历。

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

### Test Layer · 测试层

Each policy has its own test directory with pass/fail scenarios · 每个策略有独立测试目录，包含通过/失败场景：

```
test/<policy>/
├── pass.hcl                          # Test config: expects main = true
├── fail[-scenario].hcl               # Test config: expects main = false
├── mock-tfplan-pass.sentinel         # Mock Terraform plan (compliant resources)
└── mock-tfplan-fail[-scenario].sentinel  # Mock plan (non-compliant resources)
```

Test mock data simulates real Terraform plans — the same `tfplan/v2` import structure you would see from `terraform show -json` · 测试 mock 数据模拟真实的 Terraform Plan，结构与 `terraform show -json` 输出一致。

---

## Contributing · 贡献指南

1. Fork the repository
2. Add or modify policies following the existing patterns
3. Add `pass.hcl` and `fail-*.hcl` test cases with mock data
4. Run `sentinel test` to verify
5. Submit a pull request

Policy naming convention · 策略命名规范：`verb-noun[-qualifier]`（如 `restrict-cvm-instance-type`、`require-cos-encryption`）

---

## Relationship to Official Repo · 与官方仓库的关系

This repository follows the same structure and conventions as [hashicorp/terraform-sentinel-policies](https://github.com/hashicorp/terraform-sentinel-policies). The `common-functions/` modules are derived from that repository. The `tencentcloud/` directory is the Tencent Cloud equivalent of the `aws/` / `azure/` / `gcp/` directories in the official repo.

本仓库遵循与 [hashicorp/terraform-sentinel-policies](https://github.com/hashicorp/terraform-sentinel-policies) 相同的结构与约定。`common-functions/` 模块派生自该仓库。`tencentcloud/` 目录对应官方仓库中 `aws/` / `azure/` / `gcp/` 目录的腾讯云版本。

---

## License · 许可证

MPL-2.0 — see [LICENSE](LICENSE) for details.
