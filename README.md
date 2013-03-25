# Symfio

Modular framework based on Node.js and AngularJS.

## Example

```coffeescript
symfio = require "symfio"

container = symfio "fruits-example", __dirname
loader = container.get "loader"

loader.use require "symfio-contrib-express"
loader.use require "symfio-contrib-mongoose"

loader.use (container, callback) ->
  connection = container.get "connection"
  mongoose = container.get "mongoose"
  unloader = container.get "unloader"
  app = container.get "app"

  FruitSchema = new mongoose.Schema
    name: String

  Fruit = connection.model "fruits", FruitSchema

  app.get "/fruits", (req, res) ->
    Fruit.findOne (err, fruit) ->
      return res.send 500 if err
      return res.send 404 unless fruit
      res.send fruit

  unloader.register (callback) ->
    connection.db.dropDatabase ->
      callback()

  callback()

loader.load()
```

## Quick Start

Use [grunt-init-symfio](https://github.com/symfio/grunt-init-symfio) to
bootstrap your first Symfio project.

## Project Status

[![Build Status](http://teamcity.rithis.com/httpAuth/app/rest/builds/buildType:id:bt4,branch:master/statusIcon?guest=1)](http://teamcity.rithis.com/viewType.html?buildTypeId=bt4&guest=1)
[![Dependency Status](https://gemnasium.com/symfio/symfio.png)](https://gemnasium.com/symfio/symfio)

[Code Coverage Report](http://symf.io/coverage-report)

## Tests

If you haven't already done so, install [grunt](http://gruntjs.com).

Once grunt is installed, clone Symfio repository and run tests:

```shell
git clone git://github.com/symfio/symfio.git
cd symfio
npm install
grunt test
```
