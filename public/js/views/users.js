/** @jsx React.DOM */

var UserBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="userBox">
        <NamespaceFilter currentNamespace={this.state.currentNamespace} namespaces={this.props.data.namespaces} />
        <div className="userList">
          <h2>Users</h2>
          <GenericList data={{kind: "users", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
