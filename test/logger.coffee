assert = require "assert"
colors = require "colors"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Logger", ->
    container = null
    logger = null

    beforeEach ->
        container = supplier.container()
        container.set "name", "supplier"
        container.set "silent", true
        logger = supplier.logger container

    catchOutput = (wrappedFunction) ->
        message = ""

        write = process.stdout.write
        process.stdout.write = (data) ->
            message += data.toString()

        wrappedFunction()

        process.stdout.write = write
        message

    describe "info", ->
        it "should output message", ->
            logger.silent = false
            
            output = catchOutput ->
                logger.info "hello", "world"
            assert.equal "supplier #{"hello".cyan} #{"world".grey}\n", output

        it "should output name", ->
            logger.name = "test"
            logger.silent = false

            output = catchOutput ->
                logger.info "hello", "world"
            assert.equal "test #{"hello".cyan} #{"world".grey}\n", output

            output = catchOutput ->
                logger.info "hello", "world", "mest"
            assert.equal "mest #{"hello".cyan} #{"world".grey}\n", output

        it "should not output message if silent", ->
            logger.silent = true

            output = catchOutput ->
                logger.info "hello", "world"
            assert.equal "", output

        it "should output numbers", ->
            logger.silent = false

            output = catchOutput ->
                logger.info 1, 2, 3
            assert.equal "3 #{"1".cyan} #{"2".grey}\n", output

    describe "warn", ->
        it "should output message", ->
            logger.silent = false

            output = catchOutput ->
                logger.warn "hello world"
            assert.equal "supplier #{"warn".yellow} #{"hello world".grey}\n", output

    describe "error", ->
        it "should output message and terminate application", ->
            logger.silent = false
            exitCode = 0

            exit = process.exit
            process.exit = (code) ->
                exitCode = code

            output = catchOutput ->
                logger.error 123, "hello world"
            assert.equal "supplier #{"error".red} #{"hello world".grey}\n", output
            assert.equal 123, exitCode

            process.exit = exit
