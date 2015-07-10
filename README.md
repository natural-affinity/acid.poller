acid.poller
===========

Skeleton framework for asynchronous polling of resources.

Prerequisites
-------------
* Node.js (v0.10.3x)

Features
--------
* Configurable callback method
* Configurable callback interval
* Configurable maximum retry count
* Configurable model and corresponding event to listenTo
* Published events on all actions (start, retry, stop)

Project Structure
-----------------
<pre>
/
|-- bower.json: runtime and dev dependencies (backbone, jasmine)
|-- package.json: build dependencies (grunt plugins)
|-- Gruntfile.js: all grunt build, deploy, compile, serve tasks
|-- dist: deployment-ready assets
|-- test: test-ready assets
|-- spec: all component test code
    |-- scripts (coffeescript assets)
|-- src: all component code
    |-- scripts (javascript assets)
        |-- acid (ACID Poller Component)

</pre>

Usage and Documentation
-----------------------
Please ensure all dependencies have been installed prior to usage.

### Setup

Switch to the project root directory and run the `setup.sh` script (`setup.bat` for Windows):  
```bash
$ cd acid.poller
$ ./bin/setup.sh
```

### Workflow

The `grunt serve` (watch, build, test) loop is designed to accelerate development workflow:
```bash
$ grunt serve
```

Alternatively, to simply build the component, invoke:
```bash
$ grunt build
```

Alternatively, to build and execute all component tests, invoke:
```bash
$ grunt test
```

### Usage: Backbone
```javascript
Acid.Models.MyModel = Backbone.Model.extend({})

Acid.Views.MyView = Backbone.View.extend({
  className: 'row',
  template: Acid.Templates['category/template'],
  initialize: function (options) {

    //Create Poller with model and desired options
    this.poller = new Acid.Poller(this.model, {
      callable: function (model) { model.save(); }
    });

    //Subcribe to specific poller events
    this.listenTo(this.poller, 'poller:failed', this.abort);
  },
  abort: function () {
    console.log('poller failed')
  },
  render: function () {
    this.poller.start();
    this.$el.html(this.template(this.model.toJSON()));
    this.hook.html(this.el);

    return this;
  }
});

//Instantiate model and view
var model = new Acid.Models.MyModel();
var view = new Acid.Views.MyView({model: model});

```

License
-------
Released under the MIT License.  See the LICENSE file for further details.
