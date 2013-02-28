supplier = require ".."
sinon = require "sinon"
require "should"


describe "suppler.container()", ->
    describe "Container", ->
        describe "#set()", ->
            it "should contain value", ->
                container = new supplier.container.Container
                container.set "foo", "bar"
                container.container.foo.should.equal "bar"

            it "should emit event when value is setted", ->
                container = new supplier.container.Container
                listener = sinon.spy()

                container.set "test value", "previous"
                container.once "changed test value", listener
                container.set "test value", "new"
                listener.calledOnce.should.be.true
                listener.firstCall.args[0].should.equal "new"
                listener.firstCall.args[1].should.equal "previous"

        describe "#get()", ->
            it "should return default value if value isn't setted before", ->
                container = new supplier.container.Container

                container.get("undefined", "default").should.equal "default"
                container.set "undefined", false
                container.get("undefined", "default").should.be.false
