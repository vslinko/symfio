REPORTER = dot

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER)

coverage.html: lib-cov
	@COVERAGE=1 $(MAKE) test REPORTER=html-cov > coverage.html

lib-cov:
	@./node_modules/.bin/coffeeCoverage lib lib-cov > /dev/null

.PHONY: test lib-cov
