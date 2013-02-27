containerTest = require "./support/container_test"
supplier = require ".."
errors = require "../lib/supplier/errors"
shell = require "shelljs/shell"
npm = require "npm"
fs = require "fs.extra"
require "should"


describe "supplier.command()", ->
    wrapper = containerTest ->
        @stub fs, "mkdirpSync"
        @stub fs, "existsSync"
        @stub fs, "writeFileSync"

        @stub npm, "load"
        npm.commands = install: @stub()

        @stub shell, "which"
        @stub shell, "exec"

        npm.load.yields null
        npm.commands.install.yields null

        shell.which.returns "/usr/bin/git"
        shell.exec.yields null

    beforeEach wrapper.loader()
    afterEach wrapper.unloader()

    it "should check run command", wrapper.wrap (callback) ->
        e = @logger.error
        require("./../lib/supplier/command").run ->
            fs.existsSync.calledOnce.should.be.true
            fs.mkdirpSync.callCount.should.equal 6
            fs.writeFileSync.callCount.should.equal 6

            npm.load.calledOnce.should.be.true
            npm.commands.install.calledOnce.should.be.true

            shell.which.calledOnce.should.be.true
            shell.exec.callCount.should.equal 2
            
            e.notCalled.should.be.true

            callback()
