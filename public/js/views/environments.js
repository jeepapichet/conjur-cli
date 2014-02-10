/** @jsx React.DOM */

var EnvironmentListItem = React.createClass({
  render: function() {
    var groupUrl = "/ui/environments/" + encodeURIComponent(this.props.data.record.identifier);
    return (
      <tr>
        <td className="id">
          <a href={groupUrl}>
            {this.props.data.record.identifier}
          </a>
        </td>
        <td className="ownerId">
          {this.props.data.record.ownerid}
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
        <NamespaceFilter currentNamespace={this.state.currentNamespace} namespaces={this.props.data.namespaces} />
        <div className="environmentList">
          <h2>Environments</h2>
          <GenericList data={{kind: "environments", members: this.state.members}} />
        </div>
      </div>
    );
  }
});
