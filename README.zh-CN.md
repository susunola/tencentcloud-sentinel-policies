<p align="center">
  <a href="README.md">English</a> &nbsp;|&nbsp;
  <b>简体中文</b>
</p>

# 腾讯云 Sentinel 策略库

[![License](https://img.shields.io/badge/license-MPL--2.0-blue.svg)](LICENSE)
[![Sentinel](https://img.shields.io/badge/sentinel-%3E%3D0.41.0-844FBA)](https://developer.hashicorp.com/sentinel/downloads)
[![Tests](https://img.shields.io/badge/tests-50%20passing-brightgreen.svg)](#测试结果)

适用于腾讯云基础设施治理的 HashiCorp Sentinel 策略库。策略面向 [TencentCloud Terraform Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud) 管理的资源，参考 HashiCorp 官方 AWS、Azure、GCP 及 cloud-agnostic 策略库、CIS 腾讯云基准和通用云安全实践设计。

> 本项目是社区策略库，不等同于任何完整的合规认证。生产环境启用前，应结合实际架构、Provider 版本、业务要求和适用的监管标准逐项审查。

## 技术路线

本策略库采用**路线 A**（内置导入），无需编写自定义 Sentinel SDK 插件。数据来自 Terraform Cloud/Enterprise 的 `tfplan/v2` 和 `tfconfig/v2` 内置导入。`common-functions/` 封装了通用遍历逻辑，策略代码聚焦于控制意图。

```
策略文件
  │
  ├── tfplan/v2 ── common-functions/tfplan-functions/
  │                └── 资源变更和计划值检查
  │
  ├── tfconfig/v2 ─ common-functions/tfconfig-functions/
  │                 └── Provider 和配置检查
  │
  └── tencentcloud-functions/
                     └── 腾讯云资源及安全组辅助函数
```

## 目录结构

```
tencentcloud-sentinel-policies/
├── common-functions/
│   ├── tfplan-functions/       # tfplan/v2 辅助函数
│   └── tfconfig-functions/     # tfconfig/v2 辅助函数
├── tencentcloud/
│   ├── sentinel.hcl            # 策略集配置
│   ├── tencentcloud-functions/ # 腾讯云专用辅助函数
│   ├── *.sentinel              # 策略文件
│   └── test/                   # 测试用例和 Sentinel Mock
├── README.md
└── README.zh-CN.md
```

## 策略清单

### 治理与供应链

| 策略 | 强制级别 | 说明 |
|---|---|---|
| `enforce-mandatory-tags` | advisory | 强制关键资源配置所有者和成本标签 |
| `require-provider-version-constraint` | advisory | 要求 TencentCloud Provider 配置版本约束 |
| `prevent-resource-destruction` | **hard-mandatory** | 阻止销毁标记为生产或 Terraform 管理的资源 |

### 身份与访问控制

| 策略 | 强制级别 | 说明 |
|---|---|---|
| `restrict-cam-policy-actions` | advisory | 阻止 CAM Allow 策略同时使用 `Action=*` 和 `Resource=*` |
| `restrict-cam-access-key-age` | advisory | 要求 CAM 访问密钥在配置期限内轮换 |

### 计算与 Kubernetes

| 策略 | 强制级别 | 说明 |
|---|---|---|
| `restrict-cvm-instance-type` | advisory | 限制 CVM 仅使用批准的机型 |
| `restrict-cvm-image-source` | advisory | 限制 CVM 仅使用批准前缀的镜像 |
| `restrict-tke-cluster` | advisory | 要求 VPC 网络、最低 Kubernetes 版本和批准的网络插件 |

### 网络与负载均衡

| 策略 | 强制级别 | 说明 |
|---|---|---|
| `restrict-security-group-cidr` | **hard-mandatory** | 禁止关键端口接受不受限的公网入站 |
| `restrict-security-group-egress` | advisory | 禁止所有端口或数据库端口的不受限出站 |
| `restrict-clb-https` | advisory | 要求 CLB 监听器使用 HTTPS，禁止明文 HTTP |
| `restrict-clb-access-log` | advisory | 要求 CLB 开启访问日志 |
| `restrict-clb-deletion-protection` | advisory | 要求 CLB 开启删除保护 |

### COS 与存储

| 策略 | 强制级别 | 说明 |
|---|---|---|
| `restrict-cos-acl` | **hard-mandatory** | 要求 COS 使用 private ACL，并拒绝公开 Bucket Policy 主体 |
| `restrict-cos-public-access` | **hard-mandatory** | 要求 COS 开启公网访问阻断 |
| `restrict-cos-bucket-policy` | **hard-mandatory** | 拒绝包含通配符或匿名主体的 COS Bucket Policy |
| `require-cos-encryption` | advisory | 要求 COS 服务端加密 |
| `require-cos-versioning` | advisory | 要求 COS 开启对象版本控制 |
| `require-cos-logging` | advisory | 要求 COS 开启访问日志 |
| `require-cbs-encryption` | advisory | 要求 CBS 云硬盘静态加密 |

### 数据库与密钥管理

| 策略 | 强制级别 | 说明 |
|---|---|---|
| `restrict-cdb-public-access` | **hard-mandatory** | 禁止 CDB 实例公网访问 |
| `require-cdb-audit-log` | advisory | 要求 CDB 开启审计日志 |
| `require-cdb-backup-retention` | advisory | 要求配置最低备份保留天数 |
| `require-cdb-deletion-protection` | advisory | 要求 CDB 开启删除保护 |
| `require-kms-key-rotation` | advisory | 要求 KMS 密钥开启自动轮换 |

## 测试结果

仓库当前包含 **25 条策略和 50 个通过/失败测试用例**。使用 Sentinel 0.41.0 执行完整测试集全部通过：

```text
25 条策略 PASS
50 个测试用例 PASS
0 条策略失败
```

每条策略都有独立的测试目录：

```
test/<policy>/
├── pass.hcl
├── fail[-scenario].hcl
├── mock-tfplan-pass.sentinel
└── mock-tfplan-fail[-scenario].sentinel
```

Provider 版本约束策略检查 `tfconfig/v2`，因此使用 `mock-tfconfig-*.sentinel`。

## 前置条件

- [Sentinel CLI](https://developer.hashicorp.com/sentinel/downloads) 0.41.0 或兼容版本
- Terraform 及 [TencentCloud Provider](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud)
- 用于策略执行的 Terraform Cloud 或 Terraform Enterprise

## 快速开始

```bash
# 安装 Sentinel CLI
brew install hashicorp/tap/sentinel

# 运行所有策略测试
cd tencentcloud
sentinel test -verbose

# 测试单条策略
sentinel test -run restrict-security-group-cidr -verbose
```

## 在 Terraform Cloud / Enterprise 中使用

1. 在 HCP Terraform/TFE 组织中添加本仓库为策略集。
2. 查看 `tencentcloud/sentinel.hcl` 中的策略清单和强制级别。
3. 将策略集绑定到使用 TencentCloud Provider 的工作区。
4. 先在非生产工作区使用 advisory 观察违规项，再逐步提升强制级别。
5. 根据组织要求覆盖策略参数，并通过代码评审管理例外。

示例：

```hcl
policy "restrict-cvm-instance-type" {
  source            = "./tencentcloud/restrict-cvm-instance-type.sentinel"
  enforcement_level = "hard-mandatory"
  params = {
    allowed_types = ["S5.LARGE8", "S5.2XLARGE16", "S6.LARGE16"]
  }
}
```

## 主要可配置参数

| 策略 | 参数 |
|---|---|
| `restrict-cvm-instance-type` | `allowed_types` |
| `enforce-mandatory-tags` | `resource_types`、`mandatory_tags` |
| `restrict-security-group-cidr` | `forbidden_ports`、`unrestricted_cidrs` |
| `restrict-security-group-egress` | `forbidden_ports`、`unrestricted_cidrs` |
| `restrict-cvm-image-source` | `allowed_image_prefixes` |
| `restrict-tke-cluster` | `min_kubernetes_version`、`allowed_network_types` |
| `require-cdb-backup-retention` | `min_backup_retention_days` |
| `restrict-cam-policy-actions` | `forbidden_wildcard` |
| `restrict-cam-access-key-age` | `max_key_age_days` |
| `require-kms-key-rotation` | 无 |
| `require-provider-version-constraint` | 无 |
| `prevent-resource-destruction` | `protected_tags` |

## 设计参考

策略设计参考了：

- [HashiCorp Terraform Sentinel 策略示例](https://developer.hashicorp.com/terraform/cloud-docs/sentinel/examples)
- [HashiCorp Terraform Sentinel 标准化运行指南](https://developer.hashicorp.com/validated-designs/terraform-operating-guides-standardization/policy-as-code-sentinel)
- [HashiCorp terraform-sentinel-policies](https://github.com/hashicorp/terraform-sentinel-policies)
- [CIS Tencent Cloud Benchmarks](https://www.cisecurity.org/benchmark/tencent)
- 腾讯云安全与合规相关指导

跨云策略仅用于参考控制意图，不代表腾讯云资源与 AWS、Azure 或 GCP 资源具有完全相同的语义和属性。

## 贡献指南

1. Fork 本仓库。
2. 按现有命名和导入模式添加或修改策略。
3. 为每条策略增加合规和不合规测试及最小化 Mock。
4. 运行 `sentinel fmt` 和 `sentinel test -verbose`。
5. 提交 Pull Request，并注明使用的 Provider 版本和资源 Schema。

策略命名规范：`verb-noun[-qualifier]`，例如 `restrict-cvm-instance-type`、`require-cos-encryption`。

## 注意事项

- 路线 A 使用 Sentinel 内置导入，无需编写自定义 Sentinel SDK 插件。
- Sentinel 保留关键字（如 `rule`）不能作为变量名。
- `sentinel test` 要求每个测试 `.hcl` 显式声明模块，不会把策略集模块声明当作测试 fixture。
- 启用 hard-mandatory 前应核对 Provider Schema；资源属性可能随 Provider 版本变化。

## 许可证

[MPL-2.0](LICENSE)
