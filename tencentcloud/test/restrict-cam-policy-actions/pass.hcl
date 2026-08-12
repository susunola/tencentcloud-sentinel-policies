module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

param "forbidden_wildcard" {
  value = true
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
