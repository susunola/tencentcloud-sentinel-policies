param allowed_types default ["S5.MEDIUM4", "S5.LARGE8"]

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
