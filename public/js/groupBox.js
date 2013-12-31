/** @jsx React.DOM */

var GroupBox = React.createClass({
  loadGroups: function() {
    $.ajax({
      url: "/api/groups",
      success: function(data) {
        this.setState({data: data});
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {data: []};
  },
  componentWillMount: function() {
    this.loadGroups();
  },  
  render: function() {
    return (
      <div className="groupBox">
        <div className="namespaceList">
          <h1>Namespaces</h1>
          <NamespaceList data={this.state.data} />
        </div>
        <div className="groupList">
          <h1>Groups</h1>
          <GroupList data={this.state.data} />
        </div>
      </div>
    );
  }
});
