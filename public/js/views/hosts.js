/** @jsx React.DOM */

var HostBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="hostBox">
        <NamespaceFilter currentNamespace={this.state.currentNamespace} namespaces={this.props.data.namespaces} />
        <div className="hostList">
          <h2>Hosts</h2>
          <GenericList data={{kind: "hosts", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
