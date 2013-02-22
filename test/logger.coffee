assert = require "assert"
colors = require "colors"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Logger", ->
    logger = null

    beforeEach ->
        container = supplier.container()
        container.set "name", "supplier"
        container.set "silent", false
        logger = supplier.logger container

    equalOutput = (expected, wrappedFunction) ->
        message = ""

        write = process.stdout.write
        process.stdout.write = (data) ->
            message += data.toString()

        wrappedFunction()

        process.stdout.write = write
        assert.equal expected, message

    describe "info", ->
        it "should output message", ->
            equalOutput "supplier #{"hello".cyan} #{"world".grey}\n", ->
                logger.info "hello", "world"

        it "should output name", ->
            logger.name = "test"
            equalOutput "test #{"hello".cyan} #{"world".grey}\n", ->
                logger.info "hello", "world"

            equalOutput "mest #{"hello".cyan} #{"world".grey}\n", ->
                logger.info "hello", "world", "mest"

        it "should not output message if silent", ->
            logger.silent = true

            equalOutput "", ->
                logger.info "hello", "world"

        it "should output numbers", ->
            equalOutput "3 #{"1".cyan} #{"2".grey}\n", ->
                logger.info 1, 2, 3

    describe "warn", ->
        it "should output message", ->
            equalOutput "supplier #{"warn".yellow} #{"hello world".grey}\n", ->
                logger.warn "hello world"

    describe "error", ->
        it "should output message and terminate application", ->
            errorCode = 0

            exit = process.exit
            process.exit = (code) ->
                errorCode = code
                process.exit = exit

            equalOutput "supplier #{"error".red} #{"hello world".grey}\n", ->
                logger.error code: 123, message: "hello world"

            assert.equal 123, errorCode
