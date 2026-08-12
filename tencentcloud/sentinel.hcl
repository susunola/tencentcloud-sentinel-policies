module "tfplan-functions" {
  source = "../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfconfig-functions" {
  source = "../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

module "tencentcloud-functions" {
  source = "./tencentcloud-functions/tencentcloud-functions.sentinel"
}

policy "enforce-mandatory-tags" {
  source            = "./enforce-mandatory-tags.sentinel"
  enforcement_level = "advisory"
}

policy "prevent-resource-destruction" {
  source            = "./prevent-resource-destruction.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "require-cbs-encryption" {
  source            = "./require-cbs-encryption.sentinel"
  enforcement_level = "advisory"
}

policy "require-cdb-audit-log" {
  source            = "./require-cdb-audit-log.sentinel"
  enforcement_level = "advisory"
}

policy "require-cdb-backup-retention" {
  source            = "./require-cdb-backup-retention.sentinel"
  enforcement_level = "advisory"
}

policy "require-cdb-deletion-protection" {
  source            = "./require-cdb-deletion-protection.sentinel"
  enforcement_level = "advisory"
}

policy "require-cos-encryption" {
  source            = "./require-cos-encryption.sentinel"
  enforcement_level = "advisory"
}

policy "require-cos-logging" {
  source            = "./require-cos-logging.sentinel"
  enforcement_level = "advisory"
}

policy "require-cos-versioning" {
  source            = "./require-cos-versioning.sentinel"
  enforcement_level = "advisory"
}

policy "require-kms-key-rotation" {
  source            = "./require-kms-key-rotation.sentinel"
  enforcement_level = "advisory"
}

policy "require-provider-version-constraint" {
  source            = "./require-provider-version-constraint.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-cam-access-key-age" {
  source            = "./restrict-cam-access-key-age.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-cam-policy-actions" {
  source            = "./restrict-cam-policy-actions.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-cdb-public-access" {
  source            = "./restrict-cdb-public-access.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-clb-access-log" {
  source            = "./restrict-clb-access-log.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-clb-deletion-protection" {
  source            = "./restrict-clb-deletion-protection.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-clb-https" {
  source            = "./restrict-clb-https.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-cos-acl" {
  source            = "./restrict-cos-acl.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-cos-bucket-policy" {
  source            = "./restrict-cos-bucket-policy.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-cos-public-access" {
  source            = "./restrict-cos-public-access.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-cvm-image-source" {
  source            = "./restrict-cvm-image-source.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-cvm-instance-type" {
  source            = "./restrict-cvm-instance-type.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-security-group-cidr" {
  source            = "./restrict-security-group-cidr.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-security-group-egress" {
  source            = "./restrict-security-group-egress.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-tke-cluster" {
  source            = "./restrict-tke-cluster.sentinel"
  enforcement_level = "advisory"
}
