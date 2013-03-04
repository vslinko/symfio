symfio = require ".."
sinon = require "sinon"
require "should"


describe "symfio.unloader()", ->
    describe "Unloader", ->
        describe "#register()", ->
            it "should add worker to head of queue", ->
                unloader = new symfio.unloader.Unloader
                worker0 = ->
                worker1 = ->

                unloader.workers.length.should.equal 0
                unloader.register worker0
                unloader.register worker1
                unloader.workers.length.should.equal 2
                unloader.workers[0].should.equal worker1
                unloader.workers[1].should.equal worker0

        describe "#unload()", ->
            it "should run workers", ->
                unloader = new symfio.unloader.Unloader
                worker = sinon.stub().yields()

                unloader.register worker
                unloader.unload()
                worker.called.should.be.true

            it "should emit 'unloaded' after all workers is done", ->
                unloader = new symfio.unloader.Unloader
                listener = sinon.spy()
                worker = sinon.stub().yields()

                unloader.register worker
                unloader.on "unloaded", listener
                unloader.unload()
                listener.calledOnce.should.be.true

            it "should call callback after all workers is done", ->
                unloader = new symfio.unloader.Unloader
                listener = sinon.spy()
                worker = sinon.stub().yields()

                unloader.register worker
                unloader.unload listener
                listener.calledOnce.should.be.true
                unloader.unload()
                listener.calledOnce.should.be.true
