fakeContainer = require "./support/fake_container"
supplier = require ".."
bower = require "bower"
sinon = require "sinon"
fs = require "fs"
require "should"


describe "bower", ->
    installation = null
    container = null
    sandbox = null

    beforeEach ->
        sandbox = sinon.sandbox.create()
        container = fakeContainer sandbox

        sandbox.stub process, "chdir"
        sandbox.stub fs, "writeFile"
        fs.writeFile.yields null

        installation = on: sinon.stub()
        installation.on.withArgs("end").yields()

        sandbox.stub bower.commands, "install"
        bower.commands.install.returns installation

    afterEach ->
        sandbox.restore()

    it "should pipe bower output", (callback) ->
        container.set "silent", false
        container.set "components", ["jquery"]

        supplier.plugins.bower container, ->
            installation.on.withArgs("data").calledOnce.should.be.true

            sinon.stub console, "log"
            listener = installation.on.withArgs("data").firstCall.args[1]
            listener "bower"
            console.log.calledOnce.should.be.true
            console.log.firstCall.args[0].should.equal "bower"
            console.log.restore()
            callback()
