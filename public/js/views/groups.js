/** @jsx React.DOM */

var GroupBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="groupBox">
        <div className="namespaceList">
          <h1>Namespaces</h1>
          <NamespaceList data={{currentNamespace: this.state.currentNamespace, namespaces: this.props.data.namespaces}} />
        </div>
        <div className="groupList">
          <h1>Groups</h1>
          <GenericList data={{kind: "groups", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
