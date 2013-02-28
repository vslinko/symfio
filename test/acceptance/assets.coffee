example = require "../support/example"


describe "Assets example", ->
    test = unloader = null

    before (callback) ->
        example "assets", ->
            [test, unloader] = arguments
            callback()

    after (callback) ->
        unloader.unload callback

    it "should compile stylus", (callback) ->
        text = ".selector {\n  color: #f00;\n}\n"

        req = test.get "/stylus-example.css"
        req.expect 200, text, callback

    it "should compile stylus with imported nib", (callback) ->
        text = ".selector {\n  border: 1px solid #f00;\n}\n"

        req = test.get "/stylus-nib-example.css"
        req.expect 200, text, callback

    it "should compile stylus with imported responsive", (callback) ->
        text = """.selector {\n  width: 100px;\n}
        @media (max-width: 767px) {\n  .selector {\n    width: 50px;\n  }\n}\n
        """

        req = test.get "/stylus-responsive-example.css"
        req.expect 200, text, callback

    it "should compile jade", (callback) ->
        text = "<!DOCTYPE html><head><title>Test</title></head>"

        req = test.get "/jade-example.html"
        req.expect 200, text, callback

    it "should compile coffeescript", (callback) ->
        text = "(function() {\n\n  alert(\"Hello World!\");\n\n}).call(this);\n"

        req = test.get "/coffeescript-example.js"
        req.expect 200, text, callback

    it "should serve files", (callback) ->
        text = "User-agent: *\nDisallow: /\n"

        req = test.get "/robots.txt"
        req.expect 200, text, callback
