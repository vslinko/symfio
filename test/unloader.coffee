symfio = require "../index"
sinon = require "sinon"
chai = require "chai"


describe "symfio.unloader()", ->
  chai.use require "chai-as-promised"
  chai.use require "sinon-chai"
  chai.should()

  describe "Unloader", ->
    describe "#register()", ->
      it "should add worker to head of queue", ->
        unloader = new symfio.unloader.Unloader
        worker0 = ->
        worker1 = ->

        unloader.workers.should.have.length 0

        unloader.register worker0
        unloader.register worker1

        unloader.workers.should.have.length 2
        unloader.workers[0].should.equal worker1
        unloader.workers[1].should.equal worker0

    describe "#unload()", ->
      it "should run workers", (callback) ->
        unloader = new symfio.unloader.Unloader
        worker = sinon.spy()

        unloader.register worker
        unloader.unload().then ->
          worker.should.have.been.calledOnce
        .should.notify callback

      it "should emit 'unloaded' event after all workers is done", (callback) ->
        unloader = new symfio.unloader.Unloader
        listener = sinon.spy()
        worker = sinon.spy()

        unloader.register worker
        unloader.on "unloaded", listener
        unloader.unload().then ->
          listener.should.have.been.calledOnce
        .should.notify callback
