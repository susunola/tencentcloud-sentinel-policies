module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

param "allowed_image_prefixes" {
  value = ["img-"]
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
