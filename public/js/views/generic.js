/** @jsx React.DOM */

var GenericListItem = React.createClass({
  render: function() {
    var recordUrl = "/ui/" + this.props.data.kind + "/" + encodeURIComponent(this.props.data.record.identifier);
    return (
      <tr>
        <td className="id">
          <a href={recordUrl}>
            {this.props.data.record.identifier}
          </a>
        </td>
        <td className="ownerId">
          <RoleLink id={this.props.data.record.ownerid || this.props.data.record.owner} />
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
        <thead>
          <tr>
            <th>Id</th>
            <th>Owner</th>
          </tr>
        </thead>
        <tbody>
        {rows}
        </tbody>
      </table>
    );
  }
});
