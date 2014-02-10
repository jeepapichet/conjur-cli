if (typeof $ === "undefined") { throw new Error("jQuery is required") }

var VariableListModel = function(){
  var options = {
    filter: function(member) {
      var idTokens = member.id.split(':');
      var id = idTokens[idTokens.length-1];
      return id.split('/').length > 1;
    }
  };
  return ResourceListModel("variable", options);
}
