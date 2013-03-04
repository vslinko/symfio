symfio = require ".."
sinon = require "sinon"
require "colors"
require "should"


describe "symfio.logger()", ->
    it "should subscribe to silent changes", ->
        container = new symfio.container.Container
        container.set "name", "symfio"
        container.set "silent", true

        logger = symfio.logger container
        logger.silent.should.be.true

        container.set "silent", false
        logger.silent.should.be.false

    describe "Logger", ->
        describe "#info()", ->
            it "should output message", sinon.test ->
                message = "symfio #{"hello".cyan} #{"world".grey}"
                logger = new symfio.logger.Logger "symfio"

                @stub console, "log"

                logger.info "hello", "world"
                console.log.calledOnce.should.be.true
                console.log.lastCall.args[0].should.equal message

            it "should give preference to name from arguments", sinon.test ->
                message = "test #{"hello".cyan} #{"world".grey}"
                logger = new symfio.logger.Logger "symfio"

                @stub console, "log"

                logger.info "hello", "world", "test"
                console.log.calledOnce.should.be.true
                console.log.lastCall.args[0].should.equal message

            it "shouldn't output message if silent is true", sinon.test ->
                logger = new symfio.logger.Logger "symfio", true

                @stub console, "log"

                logger.info "hello", "world"
                console.log.calledOnce.should.be.false

            it "should output message if arguments is numbers", sinon.test ->
                message = "3 #{"1".cyan} #{"2".grey}"
                logger = new symfio.logger.Logger "symfio"

                @stub console, "log"

                logger.info 1, 2, 3
                console.log.calledOnce.should.be.true
                console.log.lastCall.args[0].should.equal message

        describe "#warn()", ->
            it "should output message", sinon.test ->
                message = "symfio #{"warn".yellow} #{"hello world".grey}"
                logger = new symfio.logger.Logger "symfio"

                @stub console, "log"

                logger.warn "hello world"
                console.log.calledOnce.should.be.true
                console.log.lastCall.args[0].should.equal message

        describe "#error()", ->
            it "should output message and terminate application", sinon.test ->
                message = "symfio #{"error".red} #{"hello world".grey}"
                logger = new symfio.logger.Logger "symfio"

                @stub console, "log"
                @stub process, "exit"

                logger.error code: 123, message: "hello world"
                console.log.calledOnce.should.be.true
                console.log.lastCall.args[0].should.equal message
                process.exit.calledOnce.should.be.true
