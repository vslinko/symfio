symfio = require ".."
sinon = require "sinon"
require "should"


describe "symfio.loader()", ->
    describe "Loader", ->
        describe "#use()", ->
            it "should add plugin to tail of queue", ->
                plugin0 = ->
                plugin1 = ->
                loader = new symfio.loader.Loader

                loader.plugins.length.should.equal 0
                loader.use plugin0
                loader.use plugin1
                loader.plugins.length.should.equal 2
                loader.plugins[0].should.equal plugin0
                loader.plugins[1].should.equal plugin1

        describe "#load()", ->
            it "should load plugins", ->
                loader = new symfio.loader.Loader
                plugin = sinon.stub().yields()

                loader.use plugin
                plugin.called.should.be.false
                loader.load()
                plugin.calledOnce.should.be.true

            it "should emit 'loaded' after all plugins is loaded", ->
                listener = sinon.spy()
                loader = new symfio.loader.Loader
                plugin = sinon.stub().yields()

                loader.use plugin
                loader.once "loaded", listener
                loader.load()
                listener.calledOnce.should.be.true

            it "should call callback after all plugins is loaded", ->
                listener = sinon.spy()
                loader = new symfio.loader.Loader
                plugin = sinon.stub().yields()

                loader.use plugin
                loader.load listener
                listener.calledOnce.should.be.true
                loader.load()
                listener.calledOnce.should.be.true

            it "should provide container to plugin as first argument", ->
                container = new symfio.container.Container
                loader = new symfio.loader.Loader container
                plugin = sinon.stub().yields()

                loader.use plugin
                loader.load()
                plugin.firstCall.args[0].should.equal container
