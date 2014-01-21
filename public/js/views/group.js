/** @jsx React.DOM */

var Group = React.createClass({
  render: function() {
    return (
      <div className="group">
        <h1>Group {this.props.data.id}</h1>
      </div>
    );
  }
});
