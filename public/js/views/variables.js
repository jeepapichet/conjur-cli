/** @jsx React.DOM */

var VariableBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="groupBox">
        <NamespaceFilter currentNamespace={this.state.currentNamespace} namespaces={this.props.data.namespaces} />
        <div className="groupList">
          <h2>Variables</h2>
          <GenericList data={{kind: "variables", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
