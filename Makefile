MOCHA = ./node_modules/.bin/mocha
COFFEECOVERAGE = ./node_modules/.bin/coffeeCoverage
DOCCO = ./node_modules/.bin/docco

REPORTER = dot

PLUGINS = $(filter-out %index.coffee, $(wildcard lib/supplier/plugins/*.coffee))
SOURCES = lib/supplier/index.coffee $(PLUGINS)

all: test coverage.html docs

test:
	@NODE_ENV=test $(MOCHA) \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER)

coverage.html: lib-cov
	@NODE_ENV=test COVERAGE=1 $(MOCHA) \
		--compilers coffee:coffee-script \
		--reporter html-cov > coverage.html

lib-cov:
	@$(COFFEECOVERAGE) lib lib-cov > /dev/null

docs:
	@$(DOCCO) $(SOURCES) > /dev/null

clean:
	rm -rf docs lib-cov coverage.html

.PHONY: test lib-cov docs
