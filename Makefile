# Sentinel Policies command entry points
# Usage: make help

SENTINEL := sentinel
POLICY_DIR := tencentcloud

.PHONY: help fmt test

help: ## Show available commands
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-12s %s\n", $$1, $$2}'

fmt: ## Format all Sentinel files
	$(SENTINEL) fmt -check $(POLICY_DIR)/*.sentinel $(POLICY_DIR)/**/*.sentinel common-functions/**/*.sentinel

test: ## Run all policy tests
	cd $(POLICY_DIR) && $(SENTINEL) test -verbose

test-policy: ## Test a single policy (usage: make test-policy POLICY=restrict-cvm-instance-type)
	cd $(POLICY_DIR) && $(SENTINEL) test $(POLICY) -verbose
