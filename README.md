# Supplier

Glue for Node.js modules

```coffeescript
# require supplier module
supplier = require "supplier"

# create container
container = supplier "hello world", __dirname
loader = container.get "loader"

# add dependent plugins
loader.use supplier.plugins.express
loader.use supplier.plugins.mongoose
loader.use supplier.plugins.fixtures

# define own plugin
loader.use (container, callback) ->
    # replace connection string
    loader.once "injected", ->
        container.set "connection string", "mongodb://localhost/hello_world"

    # after all dependencies is injected in container
    loader.once "configured", ->
        # get dependencies
        connection = container.get "connection"
        mongoose = container.get "mongoose"
        app = container.get "app"

        # define schemas
        MessageSchema = new mongoose.Schema
            message: type: "string"

        # define models
        Message = connection.model "messages", MessageSchema

        # define express routes
        app.get "/", (req, res) ->
            Message.find {}, (err, messages) ->
                res.send messages

        # our plugin is configured and loaded, allow to start server
        callback.loaded()

    # our plugin injected values in container
    callback.injected()
    callback.configured()
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
$ make example
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
$ make test
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
