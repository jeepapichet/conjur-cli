/** @jsx React.DOM */

var Group = React.createClass({
  render: function() {
    return (
      <tr className="group">
        <td className="groupId">
          {this.props.data.id}
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
      return <Group data={group} />;
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
