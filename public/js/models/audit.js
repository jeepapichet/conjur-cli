/**
 * An AuditStream emits audit events for one or more resources or roles.
 * 
 * @constructor
 */
var AuditStream = function(){
  var sources = {},
      self    = this;
  
  function onMessage(event){
    self.trigger('message', event);
  }
  
  function onError(error){
    console.error("AuditStream error: ", error);
    _.keys(sources).forEach(function(k){
      var src = sources[k];
      if(k == error.target){
         delete sources[k];
         src.close();
      }
    });
    self.trigger('error', error);
  }
  
  function sourceKey(kind, id){
    return kind + id == null ? '' : ':' + id;
  }
  
  function sourceUrl(kind, id){
    var url = "/api/audit/stream/" + kind;
    if(id) url += "/" + id;
    url += "?self=true";
    return url;
  }
  
  function addSource(kind, id){
    var key = sourceKey(kind, id);
    var source = sources[key];
    if(!source){
      source = new EventSource(sourceUrl(kind, id));
      source.onmessage = onMessage;
      source.onerror   = onError;
      sources[key] = source;
    }
    return source;
  }
  
  function removeSource(kind, id){
    var key = sourceKey(kind, id);
    var source = sources[key];
    if(source){
      source.close();
      delete sources[key];
      return true;
    }
    return false;
  }
  
  function removeAll(){
    var keys = _.keys(sources);
    keys.forEach(function(key){
      var source = sources[key];
      delete sources[key];
      source.close();
    });
  }
  
  _.extend(this, Backbone.Events);
  _.extend(this, {
    add: addSource,
    addRole: function(id){ addSource('role', id); },
    addResource: function(id){ addSource('resource', id); },
    removeRole: function(id){ removeSource('role', id); },
    removeResource: function(id){ removeSource('resource', id); },
    removeAll: removeAll
  });
}

window.AuditStream = AuditStream;

// A list of audit events that emits events when new ones are added
var AuditEventList = function(limit){
  this.limit = arguments.length == 0 ? 0 : limit;
  this.events = [];
  _.extend(this, Backbone.Events);
}

AuditEventList.prototype.push = function(){
  var events = this.events,
      limit  = this.limit,
      len    = events.length;
  
  var ret = events.push.apply(this.events, arguments);

  if(len != events.length){
    if(limit != 0){
      events.splice(0, events.length - limit);
    }
    this.trigger('change');
  }
  return ret;
};

AuditEventList.prototype.clear = function(){
  this.events = [];
  this.trigger('change');
}

AuditEventList.prototype.connect = function(stream){
  stream.on('message', this._onMessage.bind(this));
  return this;
};

AuditEventList.prototype.disconnect = function(stream){
  stream.off('message', this._onMessage);
  return this;
};

AuditEventList.prototype._onMessage = function(e){
  this.push(JSON.parse(e.data));
};

window.AuditEventList = AuditEventList;