/** @jsx React.DOM */

var HostLink = React.createClass({
  hostId : function() {
    return this.props.data.split(':')[2];
  },
  
  hostUrl: function() {
    return "/ui/hosts/" + encodeURIComponent(this.hostId());
  },
  
  render: function() {
    return (
      <a href={this.hostUrl()}>
        {this.hostId()}
      </a>
    );
  }
});

var Host = React.createClass({
  render: function(){
    var host = this.props.data;
    return (
      <div className="host">
        <h2> Host {host.id} </h2>
        <dl>
          <dt> Owner </dt>
          <dd> <RoleLink id={host.ownerid}/> </dd>
          <dt> Created At </dt>
          <dd> <Time timestamp={host.created_at}/> </dd>
          <dt> Permissions </dt>
          <dd> <Permissions role={host.roleid}/> </dd>
        </dl>
        <div className="audit auditHost">
          <AuditBox roles={[host.roleid]} resources={[host.resource_identifier]}/>
        </div>
      </div>
    );
  }
})
