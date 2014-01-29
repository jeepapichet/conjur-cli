/** @jsx React.DOM */

var Groups = React.createClass({
  getInitialState: function() {
    return { groups: [] };
  },

  render: function() {
    return (
      <ul>
        {
          this.state.groups.map(function(group) {
            return (
              <li key={group.id}>{group.id}</li>
            )
          })
        }
      </ul>
    );
  },

  componentWillMount: function() {
    $.get("/api/groups", function(data) {
        this.setState({groups: data});
      }.bind(this)
    );
  }
});
