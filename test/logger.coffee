supplier = require ".."
sinon = require "sinon"
require "colors"
require "should"


describe "Logger", ->
    logger = null

    beforeEach ->
        logger = new supplier.logger.Logger "supplier"

    it "should subscribe on silent changes", ->
        container = new supplier.container.Container
        container.set "name", "supplier"
        container.set "silent", true

        logger = supplier.logger container
        logger.silent.should.be.true

        container.set "silent", false
        logger.silent.should.be.false

    describe "info", ->
        it "should output message", sinon.test ->
            @stub console, "log"

            message = "supplier #{"hello".cyan} #{"world".grey}"
            logger.info "hello", "world"
            console.log.calledOnce.should.be.true
            console.log.lastCall.args[0].should.equal message

        it "should use name from argument", sinon.test ->
            @stub console, "log"

            message = "test #{"hello".cyan} #{"world".grey}"
            logger.info "hello", "world", "test"
            console.log.calledOnce.should.be.true
            console.log.lastCall.args[0].should.equal message

        it "should not output message if silent", sinon.test ->
            @stub console, "log"

            logger.silent = true
            logger.info "hello", "world"
            console.log.calledOnce.should.be.false

        it "should output numbers", sinon.test ->
            @stub console, "log"

            message = "3 #{"1".cyan} #{"2".grey}"
            logger.info 1, 2, 3
            console.log.calledOnce.should.be.true
            console.log.lastCall.args[0].should.equal message

    describe "warn", ->
        it "should output message", sinon.test ->
            @stub console, "log"

            message = "supplier #{"warn".yellow} #{"hello world".grey}"
            logger.warn "hello world"
            console.log.calledOnce.should.be.true
            console.log.lastCall.args[0].should.equal message

    describe "error", ->
        it "should output message and terminate application", sinon.test ->
            @stub console, "log"
            @stub process, "exit"

            message = "supplier #{"error".red} #{"hello world".grey}"
            logger.error code: 123, message: "hello world"
            console.log.calledOnce.should.be.true
            console.log.lastCall.args[0].should.equal message
            process.exit.calledOnce.should.be.true
