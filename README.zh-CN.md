<p align="center">
  <a href="README.md">English</a> &nbsp;|&nbsp;
  <b>简体中文</b>
</p>

# 腾讯云 Sentinel 策略库

[![License](https://img.shields.io/badge/license-MPL--2.0-blue.svg)](LICENSE)
[![Sentinel](https://img.shields.io/badge/sentinel-%3E%3D0.26.0-844FBA)](https://developer.hashicorp.com/sentinel/downloads)

适用于腾讯云基础设施治理的 HashiCorp Sentinel 策略库——为 [TencentCloud Terraform Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud) 管理的资源强制实施安全、合规与运维最佳实践。

## 技术路线

本策略库采用**路线 A**（内置导入）——无需编写自定义 Sentinel 插件。所有数据来自 Terraform Cloud/Enterprise 内置的 `tfplan/v2` 和 `tfconfig/v2` 导入。`common-functions/` 辅助模块对这些导入进行了封装，策略作者只需编写可读的、面向意图的规则，而非原始数据遍历。

```
Policy（策略文件）
  │
  ├── import "tfplan-functions" as plan
  │     └── common-functions/tfplan-functions/
  │           └── 封装 tfplan/v2（内置，无需插件）
  │
  └── import "tencentcloud-functions" as tc
        └── tencentcloud/tencentcloud-functions/
              └── 腾讯云资源发现辅助函数
```

## 目录结构

```
tencentcloud-sentinel-policies/
├── common-functions/           # 可复用 Sentinel 模块
│   ├── tfplan-functions/       # tfplan/v2 导入辅助
│   └── tfconfig-functions/     # tfconfig/v2 导入辅助
├── tencentcloud/               # 腾讯云策略集
│   ├── sentinel.hcl            # 策略集配置
│   ├── tencentcloud-functions/ # 腾讯云专用辅助函数
│   │   └── tencentcloud-functions.sentinel
│   ├── *.sentinel              # 各策略文件
│   └── test/                   # 测试用例
└── README.md
```

## 策略清单

| 策略 | 强制级别 | 说明 |
|---|---|---|
| `restrict-cvm-instance-type` | advisory | 限制 CVM 仅使用指定机型 |
| `enforce-mandatory-tags` | advisory | 强制 Owner/Environment/CostCenter/ManagedBy 标签 |
| `restrict-security-group-cidr` | **hard-mandatory** | 禁止 SSH(22)/RDP(3389)/MySQL(3306)/Redis(6379)/MongoDB(27017)/PostgreSQL(5432) 对全网开放 |
| `require-cos-encryption` | advisory | COS 存储桶必须开启服务端加密 |
| `restrict-cos-acl` | **hard-mandatory** | COS 存储桶 ACL 必须为 private |
| `restrict-clb-access-log` | advisory | CLB 实例必须开启访问日志 |
| `restrict-cdb-public-access` | **hard-mandatory** | 数据库实例禁止公网访问 |
| `validate-provider-regions` | advisory | 限制腾讯云 Provider 仅允许指定区域 |
| `protect-against-cvm-deletion` | advisory | 生产 CVM 实例必须开启销毁保护 |
| `restrict-vpc-cidr` | advisory | VPC CIDR 必须使用 RFC 1918 私有地址段 |
| `require-cbs-encryption` | advisory | CBS 云硬盘必须加密 |
| `restrict-tke-cluster` | advisory | TKE 集群强制 VPC-CNI 网络模式及最低版本要求 |

## 测试结果

```
PASS - restrict-cvm-instance-type.sentinel
  PASS - test/restrict-cvm-instance-type/fail.hcl    # 不合规机型 → 违规 ✓
  PASS - test/restrict-cvm-instance-type/pass.hcl    # 合规机型 → 通过 ✓

PASS - restrict-security-group-cidr.sentinel
  PASS - test/restrict-security-group-cidr/fail.hcl  # SSH 开放全网 → 违规 ✓
  PASS - test/restrict-security-group-cidr/pass.hcl  # 仅内网 CIDR → 通过 ✓

PASS - enforce-mandatory-tags.sentinel
  PASS - test/enforce-mandatory-tags/fail-missing-tags.hcl  # 缺少标签 → 违规 ✓
  PASS - test/enforce-mandatory-tags/pass.hcl               # 标签完整 → 通过 ✓

PASS - require-cos-encryption.sentinel
  PASS - test/require-cos-encryption/fail.hcl  # 未加密 → 违规 ✓
  PASS - test/require-cos-encryption/pass.hcl  # SSE-COS 已启用 → 通过 ✓
```

### 测试层

每个策略有独立测试目录，包含通过/失败场景：

```
test/<policy>/
├── pass.hcl                          # 测试配置：期望 main = true
├── fail[-scenario].hcl               # 测试配置：期望 main = false
├── mock-tfplan-pass.sentinel         # Mock Terraform Plan（合规资源）
└── mock-tfplan-fail[-scenario].sentinel  # Mock Plan（不合规资源）
```

测试 mock 数据模拟真实的 Terraform Plan，结构与 `terraform show -json` 输出一致。

## 前置条件

- [Sentinel CLI](https://developer.hashicorp.com/sentinel/downloads) >= 0.26.0
- Terraform >= 1.0，搭配 [TencentCloud Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud)

## 快速开始

```bash
# 安装 Sentinel CLI
brew install hashicorp/tap/sentinel

# 运行全部测试
cd tencentcloud
sentinel test -verbose

# 测试单个策略
sentinel test restrict-cvm-instance-type -verbose
```

### 在 Terraform Cloud/Enterprise 中使用

1. 在 TFC/TFE 组织中添加此仓库为策略集
2. 按需调整各策略的强制级别（默认 advisory，可在 `sentinel.hcl` 中修改）
3. 将策略集绑定到使用 TencentCloud Provider 的工作区

在策略集配置中覆盖参数：

```hcl
# 按组织需求覆盖允许的机型
policy "restrict-cvm-instance-type" {
  source            = "./tencentcloud/restrict-cvm-instance-type.sentinel"
  enforcement_level = "hard-mandatory"
  params = {
    allowed_types = ["S5.LARGE8", "S5.2XLARGE16", "S6.LARGE16"]
  }
}
```

## 参数自定义

每个策略提供可覆盖的 `param` 参数：

| 策略 | 参数 | 默认值 |
|---|---|---|
| `restrict-cvm-instance-type` | `allowed_types` | S5.MEDIUM4, S5.LARGE8, S5.2XLARGE16, S5.4XLARGE32, S6.MEDIUM4, S6.LARGE8, SA2.MEDIUM4, SA2.LARGE8, SA3.MEDIUM8, SA3.LARGE16 |
| `enforce-mandatory-tags` | `resource_types`, `mandatory_tags` | CVM/COS/CLB/MySQL/VPC/CBS/TKE/Redis; Owner, Environment, CostCenter, ManagedBy |
| `restrict-security-group-cidr` | `forbidden_ports`, `unrestricted_cidrs` | [22, 3389, 3306, 6379, 27017, 5432]; ["0.0.0.0/0", "::/0"] |
| `validate-provider-regions` | `allowed_regions` | ap-guangzhou, ap-shanghai, ap-beijing, ap-singapore |
| `restrict-tke-cluster` | `min_kubernetes_version`, `allowed_network_types` | 1.20; ["VPC-CNI"] |
| `protect-against-cvm-deletion` | `protected_tag_key`, `protected_tag_value` | Environment; Production |

## 与官方仓库的关系

本仓库遵循与 [hashicorp/terraform-sentinel-policies](https://github.com/hashicorp/terraform-sentinel-policies) 相同的结构与约定。`common-functions/` 模块派生自该仓库。`tencentcloud/` 目录对应官方仓库中 `aws/` / `azure/` / `gcp/` 目录的腾讯云版本。

## 贡献指南

1. Fork 本仓库
2. 遵循现有模式添加或修改策略
3. 添加 `pass.hcl` 和 `fail-*.hcl` 测试用例及 mock 数据
4. 运行 `sentinel test` 验证
5. 提交 Pull Request

策略命名规范：`verb-noun[-qualifier]`（如 `restrict-cvm-instance-type`、`require-cos-encryption`）。

## 注意事项

- 本策略库使用路线 A（内置导入），无需编写自定义 Sentinel SDK 插件。
- Sentinel 保留关键字（`rule` 等）不能用作变量名。
- `sentinel test` 不会读取 `sentinel.hcl`，模块导入必须在各测试 `.hcl` 文件中显式声明。
- Sentinel v0.41.0 要求使用 `param "name" { value = ... }` 语法，旧的 `param name default value` 形式已废弃。

## 许可证

[MPL-2.0](LICENSE)
