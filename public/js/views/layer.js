/** @jsx React.DOM */

var Layer = React.createClass({
  render: function() {
    function abstractRole(expected) {
      return function(role) {
        var tokens = role.split(':');
        var kind = tokens[1];
        var abstractKinds = [ '@', 'layer' ];
        var isAbstract = abstractKinds.indexOf(kind) !== -1;
        return isAbstract === expected;
      }
    }
    
    var layerId = conjurConfiguration.account + ':layer:' +  this.props.data.layer.id;
    
    var hosts = this.props.data.layer.hosts.map(function (host) {
      return <li>
        <HostLink data={host} />
      </li>
    }.bind(this));
    var admins = this.props.data.admins.filter(abstractRole(false)).map(function (role) {
      return <li>{role}</li>
    }.bind(this));
    var users = this.props.data.users.filter(abstractRole(false)).map(function (role) {
      return <li>{role}</li>
    }.bind(this));
    
    return (
      <div className="group">
        <h2>Layer {this.props.data.layer.id}</h2>
        
        <dl>
          <dt>Owner</dt>
          <dd>{this.props.data.layer.ownerid}</dd>
          <dt>Admins</dt>
          <dd>
            <ul>
              {admins}
            </ul>
          </dd>
          <dt>Users</dt>
          <dd>
            <ul>
              {users}
            </ul>
          </dd>
          <dt>Hosts</dt>
          <dd>
            <ul>
              {hosts}
            </ul>
          </dd>
        </dl>
        
        <div className="audit auditLayer">
          <AuditBox roles={[layerId]} resources={[layerId]}/>
        </div>
      </div>
    );
  }
});
