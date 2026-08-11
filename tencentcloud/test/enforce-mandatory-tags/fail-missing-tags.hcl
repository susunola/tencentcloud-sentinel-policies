param resource_types default ["tencentcloud_instance", "tencentcloud_cos_bucket"]
param mandatory_tags default ["Owner", "Environment", "CostCenter"]

mock "tfplan/v2" {
  module {
    source = "./mock-tfplan-fail.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
