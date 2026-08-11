module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tencentcloud-functions" {
  source = "../../tencentcloud-functions/tencentcloud-functions.sentinel"
}

param "resource_types" {
  value = ["tencentcloud_instance", "tencentcloud_cos_bucket"]
}
param "mandatory_tags" {
  value = ["Owner", "Environment", "CostCenter"]
}

mock "tfplan/v2" {
  module {
    source = "./mock-tfplan-pass.sentinel"
  }
}

test {
  rules = {
    main = true
  }
}
