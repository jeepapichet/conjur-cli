/** @jsx React.DOM */

var Conjur = React.createClass({
  render: function() {
    return (
      <CoreEntityList url="/api/groups" />
    );
  }
});
