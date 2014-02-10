if (typeof $ === "undefined") { throw new Error("jQuery is required") }

var ResourceListModel = function(kind, options){
  var List = function() {
    this._members = null;
    this.namespaces = null;
    this.options = options || {};
    if ( !this.options.idSelector ) {
      this.options.idSelector = function(member) {
        var idTokens = member.id.split(':');
        return idTokens[idTokens.length-1];
      }
    }
    if ( !this.options.namespaceSelector ) {
      this.options.namespaceSelector = function(member) {
        return member.identifier.split('/')[0];
      }
    }
  }
  
  List.prototype.members = function(namespace) {
    var result;
    if ( namespace === "" ) {
      result = _.clone(this._members);
    }
    else {
      result = this._members.filter(function (o) {
        return this.options.namespaceSelector(o) === namespace;
      }.bind(this));
    }
    return result.sort(function(a,b) {
      return a.identifier.localeCompare(b.identifier);
    });
  }
  
  List.prototype.fetch = function(callback) {
    if ( this._members )
      return callback(this);
    
    var self = this;
    $.ajax({
      url: "/api/authz/" + encodeURIComponent(conjurConfiguration.account) + "/resources/" + encodeURIComponent(kind),
      success: function(data) {
        var filter, idSelector;
        
        if ( filter = this.options.filter ) {
          data = _.filter(data, filter);
        }
        
        self._members = data;
        self._members.forEach(function(member) {
          member.identifier = this.options.idSelector(member);
        }.bind(this));
        self.namespaces = _.unique(self._members.map(this.options.namespaceSelector)).sort();
        callback(self);
      }.bind(this)
    });
  }
  
  return new List();
}
