/** @jsx React.DOM */

var NamespaceFilter = React.createClass({
  render: function() {
    return(
      <div className="namespaceList">
        <h2>Namespace filter:</h2>
        { this.transferPropsTo(<NamespaceList />) }
      </div>
    );
  }
});

var NamespaceListItem = React.createClass({
  render: function() {
    return (
      <option value={this.props.id}>{this.props.id}</option>
    );
  }
});

var NamespaceList = React.createClass({
  handleChange: function(e) {
    var value = e.target.options[e.target.selectedIndex].value;
    updateNamespace(value);
  },
  render: function() {
    var namespaces = this.props.namespaces.map(function (namespace) {
      return <NamespaceListItem id={namespace}/>;
    }).sort();
    return (
      <div>
        <select onChange={this.handleChange} value={this.props.currentNamespace}>
          <option value="" />
          {namespaces}
        </select>
      </div>
    );
  }
});
