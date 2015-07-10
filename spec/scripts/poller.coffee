describe 'Poller', ->
  ModelType = Backbone.Model.extend({})

  describe 'Dependencies', ->
    it 'requires window', -> expect(window).toBeDefined()
    it 'requires backbone.js', -> expect(Backbone).toBeDefined()

  describe 'Namespaces', ->
    it 'requires Acid', -> expect(Acid).toBeDefined()

  describe 'Defaults', ->
    poller = new Acid.Poller()

    it 'defaults to inactive', -> expect(poller.active).toBe false
    it 'defaults the max retry count to 5', -> expect(poller.maxRetries).toBe 5
    it 'defaults the model event to "request"', -> expect(poller.modelEvent).toBe 'request'
    it 'defaults the polling interval to 10 seconds', -> expect(poller.interval).toBe 10000
    it 'defaults the callback method to output "called" to STDOUT', ->
      spyOn console, 'log'
      poller.callable()
      expect(console.log).toHaveBeenCalledWith('called')

  describe 'Constructor', ->
    options = { interval: 5000, maxRetries: 3, callable: -> console.log ('call every interval') }
    poller = new Acid.Poller({}, options)

    it 'requires a model for binding', -> expect(poller.model).toBeDefined()
    it 'accepts a hash of parameters', ->
      spyOn console, 'log'
      poller.callable()
      expect(poller.interval).toBe 5000
      expect(poller.maxRetries).toBe 3
      expect(console.log).toHaveBeenCalledWith('call every interval')

  describe '#start', ->
    [model, poller] = [null, null]

    beforeEach ->
      jasmine.clock().install()
      model = new ModelType()
      poller = new Acid.Poller(model, { interval: 20000 })
      spyOn poller, 'trigger'
      spyOn console, 'log'
      poller.start()
      poller.start()

    afterEach ->
      jasmine.clock().uninstall()

    it 'activates the poller', -> expect(poller.active).toBe true
    it 'ignores repeated calls', -> expect(poller.trigger.calls.count()).toBe 1
    it 'listenTo the model "request" event', -> expect(model._events.request.length).toBe 1
    it 'uses window.setInterval to setup a callback', -> expect(this.intervalId).not.toBeNull()
    it 'publishes a "poller:start" event on completion', -> expect(poller.trigger).toHaveBeenCalledWith('poller:start')
    it 'executes the callable method at every interval', ->
      jasmine.clock().tick(20001)
      expect(console.log).toHaveBeenCalledWith('called')

  describe '#increment', ->
    [model, poller] = [null, null]

    beforeEach ->
      model = new ModelType()
      poller = new Acid.Poller(model, { interval: 20000, maxRetries: 1 })
      spyOn(poller, 'increment').and.callThrough()
      spyOn poller, 'trigger'
      spyOn poller, 'stop'
      poller.start()

      model.trigger('request')

    it 'runs on model "request" events', -> expect(poller.increment).toHaveBeenCalled()
    it 'increments the internal counter', -> expect(poller.count).toBe 1
    it 'publishes a "poller:retry" event', -> expect(poller.trigger).toHaveBeenCalledWith('poller:retry', 1)
    it 'resets the counter if the poller is inactive', ->
      poller.active = false
      model.trigger('request')
      expect(poller.count).toBe 0
    it 'deactivates the poller when the retry limit is reached', ->
      model.trigger('request')
      expect(poller.stop).toHaveBeenCalled()
    it 'publishes a "poller:failed" event when the retry limit is reached', ->
      model.trigger('request')
      expect(poller.trigger).toHaveBeenCalledWith('poller:failed')

  describe '#stop', ->
    [model, poller, id] = [null, null, null]

    beforeEach ->
      model = new ModelType()
      poller = new Acid.Poller(model, { interval: 20000 })
      spyOn poller, 'trigger'
      poller.start()
      id = poller.intervalId

      poller.increment()
      poller.stop()
      poller.stop()

    it 'deactivates the poller', -> expect(poller.active).toBe false
    it 'ignores repeated calls', -> expect(poller.trigger.calls.count()).toBe 3
    it 'resets the window intervalId', -> expect(poller.intervalId).toBeNull()
    it 'stops listening to the model', -> expect(poller._listeningTo).toEqual({})
    it 'resets the internal counter to zero', -> expect(poller.count).toBe 0
    it 'uses window.clearInterval to remove the callback', -> expect(window.clearInterval(id)).toBeUndefined()
