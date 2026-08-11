param "min_kubernetes_version" {
  value = "1.28"
}

param "allowed_network_types" {
  value = ["VPC-CNI", "GR"]
}

module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

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
