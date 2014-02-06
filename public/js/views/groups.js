/** @jsx React.DOM */

var GroupBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="groupBox">
        <NamespaceFilter currentNamespace={this.state.currentNamespace} namespaces={this.props.data.namespaces} />
        <div className="groupList">
          <h2>Groups</h2>
          <GenericList data={{kind: "groups", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
