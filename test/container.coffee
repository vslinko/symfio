symfio = require "../index"
sinon = require "sinon"
chai = require "chai"


describe "symfio.container()", ->
  chai.use require "sinon-chai"
  expect = chai.expect

  describe "Container", ->
    describe "#set()", ->
      it "should contain value", ->
        container = new symfio.container.Container

        container.set "foo", "bar"

        expect(container.container.foo).to.equal "bar"

      it "should emit event when value is setted", ->
        container = new symfio.container.Container
        listener = sinon.spy()

        container.set "test value", "previous"
        container.once "changed test value", listener
        container.set "test value", "new"

        expect(listener).to.have.been.calledOnce
        expect(listener).to.have.been.calledWith "new", "previous"

    describe "#get()", ->
      it "should return default value if value isn't setted before", ->
        container = new symfio.container.Container

        expect(container.get "undefined", "default").to.equal "default"

        container.set "undefined", false

        expect(container.get "undefined", "default").to.equal false
