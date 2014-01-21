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

var Layer = React.createClass({
  render: function() {
    var hosts = this.props.data.layer.hosts.map(function (host) {
      return <li>
        <HostLink data={host} />
      </li>
    }.bind(this));
    var admins = this.props.data.admins.map(function (role) {
      return <li>{role}</li>
    }.bind(this));
    
    return (
      <div className="group">
        <h1>Layer {this.props.data.layer.id}</h1>
        
        <dl>
          <dt>Owner</dt>
          <dd>{this.owner}</dd>
          <dt>Admins</dt>
          <dd>
            <ul>
              {admins}
            </ul>
          </dd>
          <dt>Users</dt>
          <dd>{this.props.data.users}</dd>
          <dt>Hosts</dt>
          <dd>
            <ul>
              {hosts}
            </ul>
          </dd>
        </dl>
      </div>
    );
  }
});
