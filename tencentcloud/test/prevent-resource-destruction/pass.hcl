param "protected_tags" {
  value = {
    "Environment" = "prod"
    "ManagedBy"   = "terraform"
  }
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
