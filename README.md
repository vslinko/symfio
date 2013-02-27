# Supplier

Glue for Node.js modules

```coffeescript
supplier = require "supplier"


container = supplier "fruits-example", __dirname
loader = container.get "loader"

loader.use supplier.plugins.express
loader.use supplier.plugins.mongoose

loader.use (container, callback) ->
    connection = container.get "connection"
    mongoose = container.get "mongoose"

    FruitSchema = new mongoose.Schema
        name: String

    connection.model "fruits", FruitSchema

    callback()

loader.use supplier.plugins.fixtures
loader.use supplier.plugins.crud

loader.use (container, callback) ->
    connection = container.get "connection"
    unloader = container.get "unloader"
    crud = container.get "crud"
    app = container.get "app"

    Fruit = connection.model "fruits"

    app.get "/fruits", crud.list(Fruit).sort(name: -1).make()

    unloader.register (callback) ->
        connection.db.dropDatabase ->
            callback()

    callback()

loader.load()
```

## Quick Start

Start new project:

```sh
$ mkdir my_project
$ cd my_project
$ git init
$ cat << END > .gitignore
node_modules
END
$ cat << END > package.json
{
    "name": "my_project",
    "version": "0.0.0",
    "public": false
}
END
```

Install Supplier:

```sh
$ npm install supplier --save
```

Create sample application:

```sh
$ cat << END > my_project.coffee
supplier = require "supplier"

container = supplier "my_project", __dirname
loader = container.get "loader"
loader.use supplier.plugins.assets
loader.use supplier.plugins.express
loader.load()
END
$ mkdir public
$ cat << END > public/index.jade
doctype 5
html
    head
        title Hello World!
    body
        h1 Hello World!
END
```

Start server:

```sh
$ coffee my_project
```

## Viewing Examples

Clone Supplier repo, then run example:

```sh
$ git clone git://github.com/rithis/supplier.git
$ cd supplier
$ npm install
$ ./node_modules/.bin/coffee examples/fruits
```

## Project Status

[![Build Status](http://teamcity.rithis.com/httpAuth/app/rest/builds/buildType:id:bt4,branch:master/statusIcon?guest=1)](http://teamcity.rithis.com/viewType.html?buildTypeId=bt4&guest=1) [![Dependency Status](https://gemnasium.com/rithis/supplier.png)](https://gemnasium.com/rithis/supplier)

[Code Coverage Report](http://teamcity.rithis.com/repository/download/bt4/.lastFinished/coverage.html)

[Latest Documentation](http://teamcity.rithis.com/repository/download/bt4/.lastFinished/docs.tar.gz!docs/supplier.html)

## Running Tests

Clone Supplier repo, then run tests:

```sh
$ git clone git://github.com/rithis/supplier.git
$ cd supplier
$ npm install
$ ./node_modules/.bin/grunt test
```

# Release Instructions

Checkout to `master` branch:

```sh
$ git checkout master
```

Increment version in `package.json` and commit:

```sh
$ git add package.json
$ git commit -m "Bumped 0.0.0"
```

Add version tag to commit in which `package.json` is changed:

```sh
$ git tag 0.0.0 HEAD
```

Push commit and tag to GitHub and wait until CI build is succeed:

```sh
$ git push origin master
$ git push origin 0.0.0
```

Upload package to NPM repository:

```sh
$ npm publish
```

Checkout to gh-pages branch:

```sh
$ git checkout gh-pages
```

Increment version in `_includes/footer.html` and update website:

```sh
$ ./_update.sh
$ git add .
$ git commit -m "Updated"
$ git push
```

Return to master branch:

```sh
$ git checkout master
```
