param forbidden_ports default [22, 3389, 3306]
param unrestricted_cidrs default ["0.0.0.0/0"]

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
