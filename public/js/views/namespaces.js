/** @jsx React.DOM */

var NamespaceListItem = React.createClass({
  render: function() {
    return (
      <option value={this.props.data.id}>{this.props.data.id}</option>
    );
  }
});

var NamespaceList = React.createClass({
  handleChange: function(e) {
    var value = e.target.options[e.target.selectedIndex].value;
    updateGroups(value);
  },
  render: function() {
    var namespaces = this.props.data.namespaces.map(function (namespace) {
      return <NamespaceListItem data={{id:namespace}}/>;
    }).sort();
    return (
      <div>
        <select onChange={this.handleChange} value={this.props.data.currentNamespace}>
          <option value="" />
          {namespaces}
        </select>
      </div>
    );
  }
});
