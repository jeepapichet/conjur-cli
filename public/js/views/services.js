/** @jsx React.DOM */

var ServiceListItem = React.createClass({
  render: function() {
    var groupUrl = "/ui/" + this.props.data.kind + "/" + encodeURIComponent(this.props.data.record.id);
    var idTokens = this.props.data.record.id.split(':');
    return (
      <tr>
        <td className="id">
          <a href={groupUrl}>
            {idTokens[idTokens.length-1]}
          </a>
        </td>
        <td className="ownerId">
          {this.props.data.record.owner}
        </td>
      </tr>
    );
  }
});

var ServiceBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="serviceBox">
        <NamespaceFilter currentNamespace={this.state.currentNamespace} namespaces={this.props.data.namespaces} />
        <div className="serviceList">
          <h2>Services</h2>
          <GenericList data={{kind: "services", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
