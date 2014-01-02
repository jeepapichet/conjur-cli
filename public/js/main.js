/**
 * @jsx React.DOM
 */
var namespace = NamespaceModel();
var kind = "groups";
var lists = {
  "groups": new ListModel("groups"),
  "layers": new ListModel("layers")
};
var components  = {};
var router;

function updateNamespace(ns) {
  namespace.currentNamespace = ns;
  components[kind].setState({currentNamespace: ns, members: lists[kind].members(ns)});
}
      
$(document).ready(function() {
  function activateList(componentFunction) {
    $(".nav-item").removeClass("active");
    $("#nav-" + kind).addClass("active");
    lists[kind].fetch(function(list) {
      var component = componentFunction(list);
      components[kind] = component;
      React.renderComponent(
        component,
        document.getElementById('content')
      );
      component.setState({currentNamespace: namespace.currentNamespace, members: list.members(namespace.currentNamespace)});
    });
  }
  
  var Workspace = Backbone.Router.extend({
    routes: {
      "ui/groups": "groups",
      "ui/layers": "layers",
    },
  
    groups: function() {
      kind = "groups";
      activateList(function(list) {
        return <GroupBox data={{namespaces: list.namespaces}} />;
      });
    },
  
    layers: function() {
      kind = "layers";
      activateList(function(list) {
        return <LayerBox data={{namespaces: list.namespaces}} />
      });
    }
  });
  
  router = new Workspace();
  Backbone.history.start({pushState: true});
  router.navigate("ui/groups", {trigger: true});
});
