/** @jsx React.DOM */

var Group = React.createClass({
  render: function() {
    var members = this.props.data.members.map(function (member) {
      return <li>
        <RoleLink id={member.member} />
      </li>
    }.bind(this));
    var resourceId = [ conjurConfiguration.account, 'group', this.props.data.group.identifier ].join(':')
    return (
      <div className="group">
        <h2>Group {this.props.data.group.identifier}</h2>
        <dl>
          <dt>Owner</dt>
          <dd><RoleLink id={this.props.data.group.ownerid}/></dd>
          <dt>Members</dt>
          <dd>
            <ul>
              {members}
            </ul>
          </dd>
        </dl>
        <div className="audit auditGroup">
          <AuditBox roles={[resourceId]}/>
        </div>
      </div>
    );
  }
});
