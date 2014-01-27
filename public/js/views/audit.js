/** @jsx React.DOM */
var AuditBox = React.createClass({
  getInitialState: function(){
    return { events: [] };
  },
  componentWillMount: function(){
    this.scroll = true;
    
    var events = new AuditStream();
    var eventList = new AuditEventList();
    var self = this;
    
    events.on('message', function(e){
      eventList.push(JSON.parse(e.data));  
    });
    
    eventList.on('change', function(){
      self.setState({events: eventList.events});
      // a few millis later we want to scroll down to the 
      // bottom, *unless* the user scrolled us somewhere else
      setTimeout(function(){
        var ref, dom;
        if(self.scroll && (ref = self.refs.auditBox) && (dom = ref.getDOMNode())){
          $(dom).animate({scrollTop: dom.scrollHeight}, 'slow');
        }
      }, 200);
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
  
  handleScroll: function(){
    // we want to check whether the user has scrolled the 
    // box down to the bottom or somewhere else.  In the former
    // case we set this.scroll to true so that we scroll to
    // the bottom as new events are added, while in the latter
    // we want to *not* scroll as events are added, and set this.scroll to false.
    var ref, dom;
    if((ref = this.refs.auditBox) && (dom = ref.getDOMNode())){
      this.scroll = Math.abs((dom.scrollTop + dom.clientHeight) - dom.scrollHeight) <= 2; // fuzzy bottom
      console.log("scrolled top=" + dom.scrollTop + ", height=" + dom.scrollHeight + ", scroll=" + this.scroll);
    }
  },
  
  render: function(){
    var events = this.state.events.map(function(e){
      return <AuditEvent data={e}/>;
    });
    return (
      <div className="auditBox" onScroll={this.handleScroll} ref="auditBox">
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