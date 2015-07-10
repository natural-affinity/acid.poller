/*globals window, console, _, Backbone */
var Acid = Acid || {};

Acid.Poller = function (model, options) {
  'use strict';
  options = options || {};
  _.extend(this, Backbone.Events);

  this.interval = options.interval || 10000;
  this.maxRetries = options.maxRetries || 5;
  this.callable = options.callable || function () { console.log('called'); };
  this.intervalId = null;
  this.active = false;
  this.count = 0;
  this.model = model;
  this.modelEvent = options.modelEvent || 'request';

  this.start = function () {
    if (this.active !== true) {
      this.active = true;
      this.listenTo(this.model, this.modelEvent, this.increment);
      this.intervalId = window.setInterval(this.callable, this.interval, this.model);
      this.trigger('poller:start');
    }
  };

  this.increment = function () {
    if (this.active && this.count === this.maxRetries) {
      this.trigger('poller:failed');
      this.stop();
    } else if (this.active) {
      this.count += 1;
      this.trigger('poller:retry', this.count);
    } else {
      this.count = 0;
    }
  };

  this.stop = function () {
    if (this.active) {
      window.clearInterval(this.intervalId);
      this.trigger('poller:stop');
      this.stopListening(this.model);
      this.count = 0;

      //todo cleanup this reference
      //this.model = null;
      this.active = false;
      this.intervalId = null;
    }
  };
};
