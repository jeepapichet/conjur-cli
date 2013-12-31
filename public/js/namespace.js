/** @jsx React.DOM */

var Namespace = React.createClass({
  render: function() {
    return (
      <tr className="namespace">
        <td className="namespaceId">
          {this.props.data.id}
        </td>
      </tr>
    );
  }
});

var NamespaceList = React.createClass({
  render: function() {
    var namespaces = _.unique(this.props.data.map(function (group) {
      return group.id.split('/')[0];
    })).sort().map(function (namespace) {
      return <Namespace data={{id:namespace}}/>;
    });
    return (
      <table className="namespaceList">
        <tr>
          <th>Id</th>
        </tr>
        {namespaces}
      </table>
    );
  }
});
