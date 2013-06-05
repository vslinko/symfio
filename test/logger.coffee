kantaina = require "kantaina"
symfio = require "../index"
sinon = require "sinon"
chai = require "chai"
clc = require "cli-color"


describe "symfio.logger()", ->
  chai.use require "sinon-chai"
  chai.should()

  describe "Logger", ->
    describe "#info()", ->
      it "should output message", sinon.test ->
        message = "symfio #{clc.cyan "hello"} #{clc.blackBright "world"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"

        logger.info "hello", "world"

        console.log.should.have.been.calledOnce
        console.log.should.have.been.calledWith message

      it "should give preference to name from arguments", sinon.test ->
        message = "test #{clc.cyan "hello"} #{clc.blackBright "world"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"

        logger.info "hello", "world", "test"

        console.log.should.have.been.calledOnce
        console.log.should.have.been.calledWith message

      it "shouldn't output message if silent is true", sinon.test ->
        logger = new symfio.logger.Logger "symfio", true

        @stub console, "log"

        logger.info "hello", "world"

        console.log.should.not.been.called

      it "should output message if arguments is numbers", sinon.test ->
        message = "3 #{clc.cyan "1"} #{clc.blackBright "2"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"

        logger.info 1, 2, 3

        console.log.should.have.been.calledOnce
        console.log.should.have.been.calledWith message

    describe "#warn()", ->
      it "should output message", sinon.test ->
        message = "symfio #{clc.yellow "warn"} #{clc.blackBright "hello world"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"

        logger.warn "hello world"

        console.log.should.have.been.calledOnce
        console.log.should.have.been.calledWith message

    describe "#error()", ->
      it "should output message and terminate application", sinon.test ->
        message = "symfio #{clc.red "error"} #{clc.blackBright "hello world"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"
        @stub process, "exit"

        logger.error "hello world", 123

        console.log.should.have.been.calledOnce
        console.log.should.have.been.calledWith message
        process.exit.should.have.been.calledOnce
