param "allowed_cidr_patterns" {
  value = [
    "10\\.[0-9]+\\.[0-9]+\\.[0-9]+\\/[0-9]+",
    "172\\.(1[6-9]|2[0-9]|3[0-1])\\.[0-9]+\\.[0-9]+\\/[0-9]+",
    "192\\.168\\.[0-9]+\\.[0-9]+\\/[0-9]+",
  ]
}

module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
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
