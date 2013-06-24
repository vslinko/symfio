# Symfio

![Symfio](https://s3-eu-west-1.amazonaws.com/vslinko/symfio/logo@2x.png)

Modular framework based on Node.js and AngularJS.

## Example

```coffeescript
symfio = require "symfio"

# create container
container = symfio "fruits-example", __dirname

# add plugins
container.use require "symfio-contrib-express"
container.use require "symfio-contrib-mongoose"

# define own plugin
container.use (container) ->
  container.set "FruitSchema", (mongoose) ->
    new mongoose.Schema
      name: String

  container.set "Fruit", (connection, FruitSchema) ->
    connection.model "fruits", FruitSchema

  container.call (app, Fruit) ->
    app.get "/fruits", (req, res) ->
      Fruit.findOne (err, fruit) ->
        return res.send 500 if err
        return res.send 404 unless fruit
        res.send fruit

# load all
container.load()
```

## Quick Start

Use [grunt-init-symfio](https://github.com/symfio/grunt-init-symfio) to
bootstrap your first Symfio project.

## Project Status

[![Build Status](http://teamcity.rithis.com/httpAuth/app/rest/builds/buildType:id:bt4,branch:master/statusIcon?guest=1)](http://teamcity.rithis.com/viewType.html?buildTypeId=bt4&guest=1)
[![Dependency Status](https://gemnasium.com/symfio/symfio.png)](https://gemnasium.com/symfio/symfio)

## Tests

If you haven't already done so, install [grunt](http://gruntjs.com).

Once grunt is installed, clone Symfio repository and run tests:

```shell
git clone git://github.com/symfio/symfio.git
cd symfio
npm test
```
