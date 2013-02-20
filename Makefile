MOCHA = ./node_modules/.bin/mocha
COFFEECOVERAGE = ./node_modules/.bin/coffeeCoverage
DOCCO = ./node_modules/.bin/docco
COFFEE = ./node_modules/.bin/coffee

REPORTER = dot

PLUGINS_SOURCES = $(wildcard lib/supplier/plugins/*.coffee)
LIBRARIES_SOURCES = lib/supplier/container.coffee lib/supplier/loader.coffee \
				    lib/supplier/logger.coffee
SUPPLIER_SOURCE = lib/supplier.coffee
SOURCES = $(SUPPLIER_SOURCE) $(LIBRARIES_SOURCES) $(PLUGINS_SOURCES)

EXAMPLE = hello_world

all: test coverage.html docs

test: node_modules
	@NODE_ENV=test $(MOCHA) \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER)

coverage.html: node_modules lib-cov
	@NODE_ENV=test COVERAGE=1 $(MOCHA) \
		--compilers coffee:coffee-script \
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
