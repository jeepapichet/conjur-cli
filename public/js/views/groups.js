/** @jsx React.DOM */

var GroupBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="groupBox">
        <div className="namespaceList">
          <h2>Namespace filter:</h2>
          <NamespaceList data={{currentNamespace: this.state.currentNamespace, namespaces: this.props.data.namespaces}} />
        </div>
        <div className="groupList">
          <h2>Groups</h2>
          <GenericList data={{kind: "groups", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
