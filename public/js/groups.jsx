/** @jsx React.DOM */

var Group = React.createClass({
  getInitialState: function() {
    return { members: [] };
  },

  render: function() {
    console.log(this.state);
    return (
      <li key={this.props.id}>
        <h2>{this.props.id}</h2>
        <ul>{
          this.state.members.map(function(member) {
            return <li>{member}</li>;
          })
        }</ul>
      </li>
    );
  },

  componentWillMount: function() {
    var account = this.props.roleid.split(":")[0];

    $.get("/api/authz/" + account + "/roles/group/" + encodeURIComponent(this.props.id) + "/?members",
      function(members) {
        console.log(arguments);
        this.setState({
          members: members.map(function(data) { return data.member; })
        });
      }.bind(this)
    );
  }
});

var Groups = React.createClass({
  getInitialState: function() {
    return { groups: [] };
  },

  render: function() {
    var groupNodes = this.state.groups.map(function(group) {
      group.key = group.id;
      return Group(group);
    });
    return (
      <ul>
        {groupNodes}
      </ul>
    );
  },

  componentWillMount: function() {
    $.get("/api/groups", function(data) {
        console.log(data);
        this.setState({groups: data});
      }.bind(this)
    );
  }
});
