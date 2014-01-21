/**
 * @jsx React.DOM
 */
var namespace = NamespaceModel();
var kind = "groups";
var lists = {
  "groups": new ListModel("groups"),
  "layers": new ListModel("layers"),
  "environments": new ListModel("environments")
};
var components  = {};
var router;

function updateNamespace(ns) {
  namespace.currentNamespace = ns;
  components[kind].setState({currentNamespace: ns, members: lists[kind].members(ns)});
}
      
$(document).ready(function() {
  _.mixin(_.str.exports());

  // Use delegation to avoid initial DOM selection and allow all matching elements to bubble
  $(document).delegate("a", "click", function(evt) {
    // Get the anchor href and protcol
    var href = $(this).attr("href");
    var protocol = this.protocol + "//";
 
    // Ensure the protocol is not part of URL, meaning its relative.
    // Stop the event bubbling to ensure the link will not cause a page refresh.
    if (href.slice(protocol.length) !== protocol) {
      evt.preventDefault();
 
      // Note by using Backbone.history.navigate, router events will not be
      // triggered.  If this is a problem, change this to navigate on your
      // router.
      Backbone.history.navigate(href, {trigger:true});
    }
  });
  
  function error(err) {
    alert("Error: " + err);
  }
  
  function activateList(componentFunction) {
    /* console.log("List", kind); */
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
  
  function activateRecord(id, componentFunction) {
    /* console.log("Record", kind, " :", id); */
    $(".nav-item").removeClass("active");
    $("#nav-" + kind).addClass("active");
    new RecordModel(kind, id).fetch(function(record) {
      /* console.log(record.object); */
      
      function doRenderComponent(component) {
        React.renderComponent(
          component,
          document.getElementById('content')
        );
      }
      
      
      var component = componentFunction(record.object, function(result) {
        doRenderComponent(result);
      });
      if ( component ) {
        doRenderComponent(component);
      }
    });
  }
  
  var Workspace = Backbone.Router.extend({
    routes: {
      "ui/groups": "groups",
      "ui/groups/:group": "group",
      "ui/layers": "layers",
      "ui/layers/:layer": "layer",
      "ui/environments": "environments",
    },
  
    group: function(group) {
      kind = "groups";
      activateRecord(group, function(record) {
        return <Group data={record} />;
      });
    },
  
    groups: function() {
      kind = "groups";
      activateList(function(list) {
        return <GroupBox data={{namespaces: list.namespaces}} />;
      });
    },

    layer: function(layer) {
      kind = "layers";
      activateRecord(layer, function(record, callback) {
        var id = record.id.split(':')[2];
        async.map(['@/layer/' + record.id + '/use_host', '@/layer/' + record.id + '/admin_host' ],
          function(role, cb) {
            $.ajax({
              url: "/api/authz/conjurops/roles/" + role + "?members",
              success: function(result) { cb(null, result) },
              error: cb
            });
          },
          function(err, results) {
            if ( err )
              error(err);
            else
              callback(<Layer data={{layer: record, users: _.pluck(results[0], 'member'), admins: _.pluck(results[1], 'member')}} />);
          });
      });
    },
  
    layers: function() {
      kind = "layers";
      activateList(function(list) {
        return <LayerBox data={{namespaces: list.namespaces}} />
      });
    },
  
    environments: function() {
      kind = "environments";
      activateList(function(list) {
        return <EnvironmentBox data={{namespaces: list.namespaces}} />
      });
    }
  });
  
  router = new Workspace();
  Backbone.history.start({pushState: true});
});
