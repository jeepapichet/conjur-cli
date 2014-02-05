/** @jsx React.DOM */

var RoleLink = React.createClass({
  render: function() {
    var kind = this.props.id.split(":")[1];
    return <span className={kind}>{this.props.id}</span>;
  }
});
