/**
 * @jsx React.DOM
 */
var namespace = NamespaceModel();
var kind = "groups";
var lists = {
  "groups": new ResourceListModel("group"),
  "layers": new ResourceListModel("layer"),
  "environments": new ResourceListModel("environment"),
  "services": new ServiceListModel(),
  "users": new UserListModel(),
  "hosts": new ResourceListModel("host")
};
var conjurConfiguration;
var components  = {};
var router;
var globalIds;

function updateNamespace(ns) {
  namespace.currentNamespace = ns;
  components[kind].setState({currentNamespace: ns, members: lists[kind].members(ns)});
}

      
$(document).ready(function() {
  // http://www.quirksmode.org/js/cookies.html
  function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ')
      c = c.substring(1, c.length);
      if (c.indexOf(nameEQ) == 0)
        return c.substring(nameEQ.length, c.length);
    }
    return null;
  }
  
  conjurConfiguration = JSON.parse(decodeURIComponent(readCookie('conjur_configuration')).replace(/\+/g, ' '));
  
  globalIds = new GlobalIds();
  
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
    setActiveNav(kind);
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
    setActiveNav(kind);
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
  
  function setActiveNav(name){
    $('.nav-item').removeClass('active');
    $('#nav-' + name).addClass('active');
  }
  
  var Workspace = Backbone.Router.extend({
    routes: {
      "ui/users": "users",
      "ui/groups": "groups",
      "ui/groups/:group": "group",
      "ui/hosts": "hosts",
      "ui/layers": "layers",
      "ui/layers/:layer": "layer",
      "ui/services": "services",
      "ui/environments": "environments",
      "ui/audit": "audit"
    },
  
    users: function() {
      kind = "users";
      activateList(function(list) {
        return <UserBox data={{namespaces: list.namespaces}} />;
      });
    },
  
    group: function(group) {
      kind = "groups";
      activateRecord(group, function(record, callback) {
        $.ajax({
          url: "/api/authz/" + conjurConfiguration.account + "/roles/group/" + record.id + "?members",
          success: function(result) {
            callback(<Group data={{group: record, members: result}} />);
          },
          error: error
        });
      });
    },
  
    groups: function() {
      kind = "groups";
      activateList(function(list) {
        return <GroupBox data={{namespaces: list.namespaces}} />;
      });
    },

    hosts: function() {
      kind = "hosts";
      activateList(function(list) {
        return <HostBox data={{namespaces: list.namespaces}} />;
      });
    },
  
    layer: function(layer) {
      kind = "layers";
      activateRecord(layer, function(record, callback) {
        var id = record.id.split(':')[2];
        async.map(['@/layer/' + record.id + '/use_host', '@/layer/' + record.id + '/admin_host' ],
          function(role, cb) {
            $.ajax({
              url: "/api/authz/" + conjurConfiguration.account + "/roles/" + role + "?members",
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
    },
    
    services: function() {
      kind = "services";
      activateList(function(list) {
        return <ServiceBox data={{namespaces: list.namespaces}} />
      });
    },
    
    audit: function(){
      setActiveNav('audit')
      React.renderComponent(
        <GlobalAudit/>,
        document.getElementById('content')
      );
    }
  });
  
  router = new Workspace();
  Backbone.history.start({pushState: true});
});
