symfio = require "../index"
sinon = require "sinon"
chai = require "chai"
clc = require "cli-color"


describe "symfio.logger()", ->
  chai.use require "sinon-chai"
  expect = chai.expect

  it "should subscribe to silent changes", ->
    container = new symfio.container.Container
    container.set "name", "symfio"
    container.set "silent", true

    logger = symfio.logger container

    expect(logger.silent).to.be.true

    container.set "silent", false

    expect(logger.silent).to.be.false

  describe "Logger", ->
    describe "#info()", ->
      it "should output message", sinon.test ->
        message = "symfio #{clc.cyan "hello"} #{clc.blackBright "world"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"

        logger.info "hello", "world"

        expect(console.log).to.have.been.calledOnce
        expect(console.log).to.have.been.calledWith message

      it "should give preference to name from arguments", sinon.test ->
        message = "test #{clc.cyan "hello"} #{clc.blackBright "world"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"

        logger.info "hello", "world", "test"

        expect(console.log).to.have.been.calledOnce
        expect(console.log).to.have.been.calledWith message

      it "shouldn't output message if silent is true", sinon.test ->
        logger = new symfio.logger.Logger "symfio", true

        @stub console, "log"

        logger.info "hello", "world"

        expect(console.log).to.not.been.called

      it "should output message if arguments is numbers", sinon.test ->
        message = "3 #{clc.cyan "1"} #{clc.blackBright "2"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"

        logger.info 1, 2, 3

        expect(console.log).to.have.been.calledOnce
        expect(console.log).to.have.been.calledWith message

    describe "#warn()", ->
      it "should output message", sinon.test ->
        message = "symfio #{clc.yellow "warn"} #{clc.blackBright "hello world"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"

        logger.warn "hello world"

        expect(console.log).to.have.been.calledOnce
        expect(console.log).to.have.been.calledWith message

    describe "#error()", ->
      it "should output message and terminate application", sinon.test ->
        message = "symfio #{clc.red "error"} #{clc.blackBright "hello world"}"
        logger = new symfio.logger.Logger "symfio"

        @stub console, "log"
        @stub process, "exit"

        logger.error "hello world", 123

        expect(console.log).to.have.been.calledOnce
        expect(console.log).to.have.been.calledWith message
        expect(process.exit).to.have.been.calledOnce
