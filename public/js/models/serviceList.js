if (typeof $ === "undefined") { throw new Error("jQuery is required") }

var ServiceListModel = function(){
  var options = {
    filter: function(member) {
      var idTokens = member.id.split(':');
      var id = idTokens[idTokens.length-1];
      // Match foo-0.1.0
      return id.match(/^\w+-\d\.\d\.\d\/(.*\/)?admin$/)
    },
    idSelector: function(member) {
      var idTokens = member.id.split(':');
      var id = idTokens[idTokens.length-1];
      return id.match(/^([^\/]+)/)[1];
    },
    namespaceSelector: function(member) {
      var idTokens = member.id.split(':');
      var id = idTokens[idTokens.length-1];
      return id.match(/^\w+-(\d\.\d\.\d)\//)[1];
    }
  };
  return ResourceListModel("group", options);
}
