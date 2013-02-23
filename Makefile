MOCHA = ./node_modules/.bin/mocha
COFFEELINT = ./node_modules/.bin/coffeelint
COFFEECOVERAGE = ./node_modules/.bin/coffeeCoverage
DOCCO = ./node_modules/.bin/docco
COFFEE = ./node_modules/.bin/coffee

TIMEOUT = 2000
REPORTER = dot

SOURCES = lib/supplier.coffee lib/supplier/container.coffee \
	lib/supplier/loader.coffee lib/supplier/logger.coffee \
	lib/supplier/errors.coffee $(wildcard lib/supplier/plugins/*.coffee)

EXAMPLE = hello_world

all: test lint coverage.html docs

test: node_modules
	@NODE_ENV=test $(MOCHA) \
		--compilers coffee:coffee-script \
		--timeout $(TIMEOUT) \
		--reporter $(REPORTER)

lint: node_modules
	@$(COFFEELINT) -f coffeelint.json -r examples -r lib -r test

coverage.html: node_modules lib-cov
	@NODE_ENV=test COVERAGE=1 $(MOCHA) \
		--compilers coffee:coffee-script \
		--timeout $(TIMEOUT) \
		--reporter html-cov > coverage.html

lib-cov: node_modules
	@$(COFFEECOVERAGE) lib lib-cov > /dev/null

docs: node_modules
	@$(DOCCO) $(SOURCES) > /dev/null

node_modules:
	@npm install

example: node_modules
	@$(COFFEE) examples/$(EXAMPLE)

clean:
	rm -rf docs lib-cov coverage.html

.PHONY: test lib-cov docs
