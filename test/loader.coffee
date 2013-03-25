symfio = require ".."
sinon = require "sinon"
chai = require "chai"


describe "symfio.loader()", ->
  chai.use require "sinon-chai"
  expect = chai.expect

  describe "Loader", ->
    describe "#use()", ->
      it "should add plugin to tail of queue", ->
        plugin0 = ->
        plugin1 = ->
        loader = new symfio.loader.Loader

        expect(loader.plugins).to.have.length 0

        loader.use plugin0
        loader.use plugin1

        expect(loader.plugins).to.have.length 2
        expect(loader.plugins[0]).to.equal plugin0
        expect(loader.plugins[1]).to.equal plugin1

    describe "#load()", ->
      it "should load plugins", ->
        loader = new symfio.loader.Loader
        plugin = sinon.stub().yields()

        loader.use plugin
        loader.load()

        expect(plugin).to.have.been.calledOnce

      it "should emit 'loaded' event after all plugins is loaded", ->
        listener = sinon.spy()
        loader = new symfio.loader.Loader
        plugin = sinon.stub().yields()

        loader.use plugin
        loader.once "loaded", listener
        loader.load()

        expect(listener).to.have.been.calledOnce

      it "should provide container to plugin as first argument", ->
        container = new symfio.container.Container
        loader = new symfio.loader.Loader container
        plugin = sinon.stub().yields()

        loader.use plugin
        loader.load()

        expect(plugin).to.have.been.calledOnce
        expect(plugin).to.have.been.calledWith container
