
.PHONY: cqfd
cqfd:
	@git submodule update --init > /dev/null
	@./scripts/cqfd/cqfd init > /dev/null
	@./scripts/cqfd/cqfd run make cloc tests | grep -v '^Cscope logging'

.PHONY: dev
dev:
	@git submodule update --init > /dev/null
	@./scripts/cqfd/cqfd init > /dev/null
	@./scripts/cqfd/cqfd run nvim -u tests/dev/init.lua tests/fixtures/default/arch/arm/kernel/setup.c

.PHONY: test tests
test tests:
	@cog check --from-latest-tag
	@./scripts/run_tests

.PHONY: cloc
cloc:
	@./scripts/print_cloc
