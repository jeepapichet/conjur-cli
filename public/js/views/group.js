/** @jsx React.DOM */

var Group = React.createClass({
  render: function() {
    var members = this.props.data.members.map(function (member) {
      return <li>
        <RoleLink data={member} />
      </li>
    }.bind(this));

    return (
      <div className="group">
        <h1>Group {this.props.data.group.id}</h1>
        <dl>
          <dt>Owner</dt>
          <dd>{this.props.data.group.ownerid}</dd>
          <dt>Members</dt>
          <dd>
            <ul>
              {members}
            </ul>
          </dd>
        </dl>
      </div>
    );
  }
});
