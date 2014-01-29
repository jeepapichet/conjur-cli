/** @jsx React.DOM */

var Entity = React.createClass({
  render: function() {
    var kind, account, id;
    var pieces = this.props.roleid.split(":");
    account = pieces[0];
    kind = pieces[1];
    id = pieces[2];

    switch(kind) {
      case "group":
        return Group(this.props);
      default:
        return (<li className={"entity " + kind}>{id}</li>);
    }
  }
});

var Group = React.createClass({
  getInitialState: function() {
    return { members: [] };
  },

  render: function() {
    var id = this.props.roleid.split(":")[2];
    return (
      <li className="entity group" key={this.props.roleid}>
        <h2>{id}</h2>
        <EntityList entities={this.state.members} />
      </li>
    );
  },

  componentWillMount: function() {
    var parts = this.props.roleid.split(":");

    $.get("/api/authz/" + parts[0] + "/roles/group/" + encodeURIComponent(parts[2]) + "/?members",
      function(members) {
        console.log(arguments);
        this.setState({
          members: members.map(function(data) { return { roleid: data.member }; })
        });
      }.bind(this)
    );
  }
});

var EntityList = React.createClass({
  render: function() {
    return (
      <ul className="entity-list">{
        this.props.entities.map(function(entity) {
          entity.key = entity.roleid;
          return Entity(entity);
        })
      }</ul>
    );
  }
})

var CoreEntityList = React.createClass({
  getInitialState: function() {
    return { entities: [] };
  },

  render: function() {
    return <EntityList entities={this.state.entities}/>;
  },

  componentWillMount: function() {
    $.get(this.props.url, function(data) {
        console.log(data);
        this.setState({entities: data});
      }.bind(this)
    );
  }
});
