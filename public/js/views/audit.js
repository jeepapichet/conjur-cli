/** @jsx React.DOM */
var AuditBox = React.createClass({
  getInitialState: function(){
    return { events: [] };
  },
  componentWillMount: function(){
    var events = new AuditStream();
    var eventList = new AuditEventList();
    var self = this;
    events.on('message', function(e){
      eventList.push(JSON.parse(e.data));  
    });
    eventList.on('change', function(){
      self.setState({events: eventList.events});
    });
    if(this.props.roles){
      this.props.roles.forEach(function(roleId){
        events.addRole(roleId);
      });
    }
    if(this.props.resources){
      this.props.resources.forEach(function(resourceId){
        events.addResource(resourceId);
      });
    }
    this.events = events;
  },
  componentWillUnmount: function(){
    this.events.removeAll();
  },
  render: function(){
    var events = this.state.events.map(function(e){
      return <AuditEvent data={e}/>;
    });
    return (
      <div className="auditBox">
        {events}
      </div>
    );
  }
});

var AuditEvent = React.createClass({
  render: function(){
    var evt = this.props.data;
    var title = evt.asset + ":" + evt.action;
    var what = evt.asset == 'resource' ? 
      evt.resources[0] : evt.roles[0];
    var description = " on " + what;
    return (
      <div className="alert alert-info auditEvent">
        <strong>{title}</strong> {description}
      </div>
    );
  }
});