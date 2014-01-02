/**
 * @jsx React.DOM
 */
var namespace = NamespaceModel();
var kind = "groups";
var lists = {
  "groups": new ListModel("groups")
};
var components  = {};

function updateNamespace(ns) {
  namespace.currentNamespace = ns;
  components[kind].setState({currentNamespace: ns, members: lists[kind].filter(ns)});
}
      
$(document).ready(function() {
  lists.groups.fetch(function(list) {
    var component = <GroupBox data={{namespaces: list.namespaces}} />;
    components[kind] = component;
    React.renderComponent(
      component,
      document.getElementById('content')
    );
    component.setState({currentNamespace: namespace.currentNamespace, members: list.members()});
  });
});
