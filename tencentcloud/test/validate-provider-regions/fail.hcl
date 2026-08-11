param "allowed_regions" {
  value = ["ap-guangzhou", "ap-shanghai", "ap-beijing", "ap-singapore"]
}

mock "tfplan/v2" {
  module {
    source = "./mock-tfplan-fail.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "./mock-tfconfig-fail.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
