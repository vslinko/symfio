childProcess = require "child_process"
supertest = require "supertest"
assert = require "assert"


describe "Example", ->
    coffee = "#{__dirname}/../node_modules/.bin/coffee"
    test = supertest "http://127.0.0.1:3000"

    describe "hello_world", ->
        example = "#{__dirname}/../examples/hello_world"

        it "should run", (callback) ->
            example = childProcess.spawn coffee, [example],
                env: NODE_ENV: "production", PATH: process.env.PATH

            output = ""
            example.stdout.on "data", (data) ->
                output += data.toString()
                example.emit "started" if output.indexOf("3000") >= 0

            example.on "started", ->
                req = test.get "/"
                req.end (err, res) ->
                    assert.equal 200, res.status
                    assert.equal "Hello World!", res.body[0].message

                    example.on "exit", ->
                        callback()

                    example.kill()
