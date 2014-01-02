if (typeof $ === "undefined") { throw new Error("jQuery is required") }

var ListModel = function(kind){
  var List = function() {
    this._members = [];
    this.namespaces = []
  }
  
  List.prototype.members = function() {
    return this.filter("");
  }
  
  List.prototype.filter = function(namespace) {
    var result;
    if ( namespace === "" ) {
      result = _.clone(this._members);
    }
    else {
      result = this._members.filter(function (o) {
        return o.id.split('/')[0] === namespace;
      });
    }
    return result.sort(function(a,b) {
      return a.id.localeCompare(b.id);
    });
  }
  
  List.prototype.fetch = function(callback) {
    var self = this;
    $.ajax({
      url: "/api/" + kind,
      success: function(data) {
        self._members = data;
        self.namespaces = _.unique(self._members.map(function (o) {
          return o.id.split('/')[0];
        })).sort();
        callback(self);
      }
    });
  }
  
  return new List();
}
