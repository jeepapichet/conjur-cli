/** @jsx React.DOM */

var LayerBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="layerBox">
        <div className="namespaceList">
          <h1>Namespaces</h1>
          <NamespaceList data={{currentNamespace: this.state.currentNamespace, namespaces: this.props.data.namespaces}} />
        </div>
        <div className="layerList">
          <h1>Layers</h1>
          <GenericList data={{kind: "layers", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
