module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tencentcloud-functions" {
  source = "../../tencentcloud-functions/tencentcloud-functions.sentinel"
}

param "forbidden_ports" {
  value = [3306, 6379, 27017, 1433, 5432]
}
param "unrestricted_cidrs" {
  value = ["0.0.0.0/0"]
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
