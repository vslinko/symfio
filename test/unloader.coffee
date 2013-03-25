symfio = require ".."
sinon = require "sinon"
chai = require "chai"


describe "symfio.unloader()", ->
  chai.use require "sinon-chai"
  expect = chai.expect

  describe "Unloader", ->
    describe "#register()", ->
      it "should add worker to head of queue", ->
        unloader = new symfio.unloader.Unloader
        worker0 = ->
        worker1 = ->

        expect(unloader.workers).to.have.length 0

        unloader.register worker0
        unloader.register worker1

        expect(unloader.workers).to.have.length 2
        expect(unloader.workers[0]).to.equal worker1
        expect(unloader.workers[1]).to.equal worker0

    describe "#unload()", ->
      it "should run workers", ->
        unloader = new symfio.unloader.Unloader
        worker = sinon.stub().yields()

        unloader.register worker
        unloader.unload()

        expect(worker).to.have.been.calledOnce

      it "should emit 'unloaded' event after all workers is done", ->
        unloader = new symfio.unloader.Unloader
        listener = sinon.spy()
        worker = sinon.stub().yields()

        unloader.register worker
        unloader.on "unloaded", listener
        unloader.unload()

        expect(listener).to.have.been.calledOnce
