if (typeof $ === "undefined") { throw new Error("jQuery is required") }

var RecordModel = function(kind, id){
  var Record = function() {
    this.object = null;
  }
  
  Record.prototype.fetch = function(callback) {
    var self = this;
    $.ajax({
      url: "/api/" + kind + "/" + encodeURIComponent(id),
      success: function(data) {
        self.object = data;
        callback(self);
      }
    });
  }
  
  return new Record();
}
