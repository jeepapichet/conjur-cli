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
    addRole: function(id){ addSource('role', id); },
    addResource: function(id){ addSource('resource', id); },
    removeRole: function(id){ removeSource('role', id); },
    removeResource: function(id){ removeSource('resource', id); },
    removeAll: removeAll
  });
}

window.AuditStream = AuditStream;