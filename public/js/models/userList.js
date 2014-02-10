if (typeof $ === "undefined") { throw new Error("jQuery is required") }

var UserListModel = function(){
  var options = {
    namespaceSelector: function(member) {
      var idTokens = member.id.split('@');
      if ( idTokens.length > 1 ) {
        return idTokens.slice(1, idTokens.length-1).join['@'];
      }
      else {
        return null;
      }
    }
  };
  return ResourceListModel("user", options);
}
