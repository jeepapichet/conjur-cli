/** @jsx React.DOM */

var EnvironmentListItem = React.createClass({
  render: function() {
    var groupUrl = "/ui/environments/" + encodeURIComponent(this.props.data.record.id);
    return (
      <tr>
        <td className="id">
          <a href={groupUrl}>
            {this.props.data.record.id}
          </a>
        </td>
        <td className="ownerId">
          {this.props.data.record.ownerid}
        </td>
        <td className="variableKeys">
          {_.keys(this.props.data.record.variables).join(', ')}
        </td>
      </tr>
    );
  }
});

var EnvironmentBox = React.createClass({
  getInitialState: function() {
    return { currentNamespace: "", members: [] };
  },
  render: function() {
    return (
      <div className="environmentBox">
        <div className="namespaceList">
          <h2>Namespaces</h2>
          <NamespaceList data={{currentNamespace: this.state.currentNamespace, namespaces: this.props.data.namespaces}} />
        </div>
        <div className="environmentList">
          <h2>Environments</h2>
          <GenericList data={{kind: "environments", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
