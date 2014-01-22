/** @jsx React.DOM */

var GenericListItem = React.createClass({
  render: function() {
    var groupUrl = "/ui/" + this.props.data.kind + "/" + encodeURIComponent(this.props.data.record.id);
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
      </tr>
    );
  }
});

var GenericList = React.createClass({
  render: function() {
    var rows = this.props.data.members.map(function (o) {
      var componentName = _.str.capitalize(this.props.data.kind.substring(0, this.props.data.kind.length-1)) + "ListItem";
      var itemKind = window[componentName] || GenericListItem;
      return itemKind({data: {kind: this.props.data.kind, record: o}});
    }.bind(this));
    return (
      <table className={this.props.data.kind + "List"}>
        <tr>
          <th>Id</th>
          <th>Owner</th>
        </tr>
        {rows}
      </table>
    );
  }
});