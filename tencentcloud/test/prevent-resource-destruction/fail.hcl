param "protected_tags" {
  value = {
    "Environment" = "prod"
    "ManagedBy"   = "terraform"
  }
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
