/** @jsx React.DOM */

var Group = React.createClass({
  render: function() {
    var members = this.props.data.members.map(function (member) {
      return <li>
        <RoleLink id={member.member} />
      </li>
    }.bind(this));
    var resourceId = [ conjurConfiguration.account, 'group', this.props.data.group.id ].join(':')
    var group = this.props.data.group;
    console.log("group=", group);
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
          <dt>Permissions</dt>
          <dd>
            <Permissions role={group.roleid}/>
          </dd>
        </dl>
        <div className="audit auditGroup">
          <AuditBox roles={[resourceId]}/>
        </div>
      </div>
    );
  }
});
