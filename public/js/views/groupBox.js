/** @jsx React.DOM */

var GroupBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", groups: [] };
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
          <GroupList data={this.state.groups} />
        </div>
      </div>
    );
  }
});
