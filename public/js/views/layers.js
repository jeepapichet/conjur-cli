/** @jsx React.DOM */

var LayerBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="layerBox">
        <NamespaceFilter currentNamespace={this.state.currentNamespace} namespaces={this.props.data.namespaces} />
        <div className="layerList">
          <h2>Layers</h2>
          <GenericList data={{kind: "layers", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
