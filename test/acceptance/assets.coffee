exampleTest = require "../support/example_test"

describe "assets", ->
  wrapper = exampleTest "assets"

  before wrapper.loader()
  after wrapper.unloader()

  describe "GET /stylus-example.css", ->
    it "should respond with compiled stylus", wrapper.wrap (callback) ->
      text = ".selector {\n  color: #f00;\n}\n"

      req = @get "/stylus-example.css"
      req.expect 200, text, callback

  describe "GET /stylus-nib-example.css", ->
    it "should respond with compiled stylus with imported nib",
      wrapper.wrap (callback) ->
        text = ".selector {\n  border: 1px solid #f00;\n}\n"

        req = @get "/stylus-nib-example.css"
        req.expect 200, text, callback

  describe "GET /stylus-responsive-example.css", ->
    it "should respond with compiled stylus with imported responsive",
      wrapper.wrap (callback) ->
        text = """
        .selector {
          width: 100px;
        }
        @media (max-width: 767px) {
          .selector {
            width: 50px;
          }
        }\n
        """

        req = @get "/stylus-responsive-example.css"
        req.expect 200, text, callback

  describe "GET /jade-example.html", ->
    it "should respond with compiled jade", wrapper.wrap (callback) ->
      text = "<!DOCTYPE html><head><title>Test</title></head>"

      req = @get "/jade-example.html"
      req.expect 200, text, callback

  describe "GET /coffeescript-example.js", ->
    it "should respond with compiled coffeescript", wrapper.wrap (callback) ->
      text = "(function() {\n  alert(\"Hello World!\");\n\n}).call(this);\n"

      req = @get "/coffeescript-example.js"
      req.expect 200, text, callback

  describe "GET /robots.txt", ->
    it "should respond with static file", wrapper.wrap (callback) ->
      text = "User-agent: *\nDisallow: /\n"

      req = @get "/robots.txt"
      req.expect 200, text, callback
