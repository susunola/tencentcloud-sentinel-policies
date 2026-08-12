module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tencentcloud-functions" {
  source = "../../tencentcloud-functions/tencentcloud-functions.sentinel"
}

mock "tfplan/v2" {
  module {
    source = "./mock-tfplan-fail-database-range.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
