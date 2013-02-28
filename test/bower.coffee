containerTest = require "./support/container_test"
supplier = require ".."
bower = require "bower"
fs = require "fs"
require "should"


describe "supplier.plugins.bower()", ->
    wrapper = containerTest ->
        @installation = on: @stub()

        @stub process, "chdir"
        @stub fs, "writeFile"
        @stub console, "log"
        @stub bower.commands, "install"

        fs.writeFile.yields null
        @installation.on.withArgs("end").yields()
        bower.commands.install.returns @installation

        @container.set "public directory", __dirname
        @container.set "silent", false

    beforeEach wrapper.loader()
    afterEach wrapper.unloader()

    it "should pipe bower output", wrapper.wrap (callback) ->
        @container.set "components", ["jquery"]
        supplier.plugins.bower @container, =>
            @installation.on.withArgs("data").calledOnce.should.be.true
            listener = @installation.on.withArgs("data").firstCall.args[1]
            listener "bower"
            console.log.calledOnce.should.be.true
            console.log.firstCall.args[0].should.equal "bower"
            console.log.restore()
            callback()

    it "should not install components if no components is provided",
        wrapper.wrap (callback) ->
            supplier.plugins.bower @container, =>
                bower.commands.install.called.should.be.false
                callback()
