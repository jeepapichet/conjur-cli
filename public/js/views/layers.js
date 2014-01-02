/** @jsx React.DOM */

var LayerListItem = React.createClass({
  render: function() {
    var layerUrl = "#kind=layer;id=" + encodeURIComponent(this.props.data.id);
    return (
      <tr className="layer">
        <td className="layerId">
          <a href={layerUrl}>
            {this.props.data.id}
          </a>
        </td>
        <td className="ownerId">
          {this.props.data.ownerid}
        </td>
      </tr>
    );
  }
});

var LayerList = React.createClass({
  render: function() {
    var layerNodes = this.props.data.map(function (layer) {
      return <LayerListItem data={layer} />;
    });
    return (
      <table className="layerList">
        <tr>
          <th>Id</th>
          <th>Owner</th>
        </tr>
        {layerNodes}
      </table>
    );
  }
});

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
          <LayerList data={this.state.members} />
        </div>
      </div>
    );
  }
});
