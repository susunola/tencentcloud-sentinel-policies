# Tencent Cloud provider schema verification

This file records the Tencent Cloud Terraform Provider schema used by the Sentinel policies. It is a source-of-truth checklist for policy maintenance; cross-cloud policy names are not sufficient evidence that an attribute exists in Tencent Cloud.

Verified against `tencentcloudstack/tencentcloud` provider documentation published with version `1.83.21` on 2026-08-07.

## Verified controls

| Policy | Resource | Attribute(s) | Type / semantics | Source |
|---|---|---|---|---|
| `require-cos-encryption` | `tencentcloud_cos_bucket` | `encryption_algorithm` | String; `AES256`, `KMS`, `SM4` | `website/docs/r/cos_bucket.html.markdown` |
| `restrict-cos-acl` | `tencentcloud_cos_bucket` | `acl` | String; `private`, `public-read`, `public-read-write` | `website/docs/r/cos_bucket.html.markdown` |
| `require-cos-versioning` | `tencentcloud_cos_bucket`; `tencentcloud_cos_bucket_version` | `versioning_enable`; `status` | Bool; or String `Enabled` | `website/docs/r/cos_bucket.html.markdown`, `cos_bucket_version.html.markdown` |
| `require-cos-logging` | `tencentcloud_cos_bucket` | `log_enable`, `log_target_bucket` | Bool + String | `website/docs/r/cos_bucket.html.markdown` |
| `restrict-cos-bucket-policy` | `tencentcloud_cos_bucket_policy` | `policy` | JSON document; validate Tencent CAM/COS semantics separately | `website/docs/r/cos_bucket_policy.html.markdown` |
| `require-cdb-audit-log` | `tencentcloud_mysql_audit_service` | `audit_all`, `log_expire_day` | Bool + Int; audit service is a separate resource | `website/docs/r/mysql_audit_service.html.markdown` |
| `require-cdb-backup-retention` | `tencentcloud_mysql_backup_policy` | `retention_period` | Int; minimum 7 days | `website/docs/r/mysql_backup_policy.html.markdown` |
| `require-cdb-deletion-protection` | `tencentcloud_mysql_instance` | `force_delete` | Bool; `true` bypasses recycle-bin recovery | `website/docs/r/mysql_instance.html.markdown` |
| `restrict-cdb-public-access` | `tencentcloud_mysql_instance` | `internet_service` | Int; `0` private, `1` public | `website/docs/r/mysql_instance.html.markdown` |
| `restrict-clb-deletion-protection` | `tencentcloud_clb_instance` | `delete_protect` | Bool | `website/docs/r/clb_instance.html.markdown` |
| `restrict-clb-access-log` | `tencentcloud_clb_instance` | `log_set_id` | String; CLB log-set ID | `website/docs/r/clb_instance.html.markdown` |
| `restrict-security-group-cidr` | `tencentcloud_security_group`, `tencentcloud_security_group_rule_set` | `action`, `cidr_block`, `port` | `action` is `ACCEPT`/`DROP`; `port` is a String: `all`, single, list, or range | `website/docs/r/security_group_rule_set.html.markdown` |
| `restrict-security-group-egress` | `tencentcloud_security_group`, `tencentcloud_security_group_rule_set` | `action`, `cidr_block`, `port` | Same rule schema as ingress | `website/docs/r/security_group_rule_set.html.markdown` |
| `restrict-cam-policy-actions` | `tencentcloud_cam_policy` | `document` | Tencent CAM JSON uses lower-case `statement`, `effect`, `action`, `resource`; action/resource arrays are supported | `website/docs/r/cam_policy.html.markdown` |
| `require-kms-key-rotation` | `tencentcloud_kms_key` | `key_rotation_enabled` | Bool; valid for `ENCRYPT_DECRYPT` keys | `website/docs/r/kms_key.html.markdown` |
| `restrict-cam-access-key-age` | — | — | Not implementable from the provider plan: `tencentcloud_cam_access_key` exposes no `create_time` attribute | `website/docs/r/cam_access_key.html.markdown` |
| `restrict-cos-public-access` | — | — | No `public_access_block` argument exists on `tencentcloud_cos_bucket` | `website/docs/r/cos_bucket.html.markdown` |

## Rules for adding a policy

1. Confirm the exact provider resource name and attribute name in the provider documentation or provider source.
2. Confirm the attribute type and whether it is an argument, nested block, computed value, or separate resource.
3. Add a compliant and non-compliant mock using the exact type and value representation. Do not change a mock's type to make a policy pass.
4. For cross-resource controls, document what the policy can prove at plan time and what it cannot prove without state or runtime CSPM data.
5. Record the provider version and source path in this table.
6. Run the full Sentinel test suite and review at least one mock against a real Terraform plan shape before hard-mandatory enforcement.

## Explicit non-goals

- Sentinel plan policies do not prove that an out-of-band resource exists when Terraform has no corresponding resource change.
- Sentinel plan policies cannot reliably determine CAM access-key age when the provider does not expose a creation timestamp.
- Tencent Cloud does not have AWS S3's `public_access_block` argument; COS public-access prevention must use Tencent-specific ACL and policy controls.
