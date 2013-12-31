/** @jsx React.DOM */

var GroupListItem = React.createClass({
  render: function() {
    var groupUrl = "#kind=group;id=" + encodeURIComponent(this.props.data.id);
    return (
      <tr className="group">
        <td className="groupId">
          <a href={groupUrl}>
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

var GroupList = React.createClass({
  render: function() {
    var groupNodes = this.props.data.map(function (group) {
      return <GroupListItem data={group} />;
    });
    return (
      <table className="groupList">
        <tr>
          <th>Id</th>
          <th>Owner</th>
        </tr>
        {groupNodes}
      </table>
    );
  }
});

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
