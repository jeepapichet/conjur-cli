/** @jsx React.DOM */

var User = React.createClass({
  render: function(){
    var user = this.props.data;
    console.log("render User data=", user);
    return (
      <div className="user">
        <h2> User {user.login} </h2>
        <dl>
          <dt> Owner </dt>
          <dd><RoleLink id={user.ownerid}/></dd>
          <dt> Permissions </dt>
          <dd> <Permissions role={user.roleid}/> </dd>
        </dl>
        <div className="audit auditGroup">
          <AuditBox roles={[user.roleid]} resources={[user.resource_identifier]}/>
        </div>
      </div>
      
    );
  }
});