module "tfplan-functions" {
  source = "../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfconfig-functions" {
  source = "../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

module "tencentcloud-functions" {
  source = "./tencentcloud-functions/tencentcloud-functions.sentinel"
}

policy "restrict-cvm-instance-type" {
  source            = "./restrict-cvm-instance-type.sentinel"
  enforcement_level = "advisory"
}

policy "enforce-mandatory-tags" {
  source            = "./enforce-mandatory-tags.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-security-group-cidr" {
  source            = "./restrict-security-group-cidr.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "require-cos-encryption" {
  source            = "./require-cos-encryption.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-cos-acl" {
  source            = "./restrict-cos-acl.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "restrict-clb-access-log" {
  source            = "./restrict-clb-access-log.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-cdb-public-access" {
  source            = "./restrict-cdb-public-access.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "validate-provider-regions" {
  source            = "./validate-provider-regions.sentinel"
  enforcement_level = "advisory"
}

policy "protect-against-cvm-deletion" {
  source            = "./protect-against-cvm-deletion.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-vpc-cidr" {
  source            = "./restrict-vpc-cidr.sentinel"
  enforcement_level = "advisory"
}

policy "require-cbs-encryption" {
  source            = "./require-cbs-encryption.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-tke-cluster" {
  source            = "./restrict-tke-cluster.sentinel"
  enforcement_level = "advisory"
}
