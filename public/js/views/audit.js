/** @jsx React.DOM */

function humanizeArray(array){
  if(array.length == 0){
    return "";
  }
  if(array.length == 1){
    return array[0];
  }
  var slice = array.slice(0,-1);
  return slice.join(", ") + " and " + array[array.length - 1];
}

var AuditBox = React.createClass({
  getInitialState: function(){
    return { 
      active: true,
      events: []
    };
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


    this.events = events;
    
    this.addStreams();
    
  },
  
  componentWillUnmount: function(){
    this.events.removeAll();
  },
  
  toggleActive: function(){
    if(this.state.active){
      this.events.removeAll();
    }else{
      this.addStreams();
    }
    this.setState({active: !this.state.active});
  },
  
  addStreams: function(){
    var events = this.events;
    (this.props.roles || []).forEach(events.addRole.bind(events));
    (this.props.resources || []).forEach(events.addResource.bind(events));
  },
  
  showOptions: function(){
    
  },
  
  title: function(){
    var resources = this.props.resources || [];
    var roles = this.props.roles || [];
    console.log(resources,roles);
    var title = "Auditing ";
    if(resources.length){
      title += "resource" + (resources.length == 1 ? '' : 's') + " " + humanizeArray(resources) + " ";
      if(roles.length) title += "and ";
    }
    if(roles.length){
      title += "role" + (roles.length == 1 ? '' : 's') + " "  + humanizeArray(roles) + " ";
    }
    
    return title;
  },
  
  render: function(){
    var events = this.state.events.map(function(e){
      return <AuditEvent data={e}/>;
    });
    var playClasses = React.addons.classSet({
      'glyphicon': true, 
      'glyphicon-play': !this.state.active,
      'glyphicon-pause': this.state.active
    });
    return (
      <div className="panel panel-default">
        <div className="panel-heading">
          <strong>{this.title()}</strong>
          <div className="pull-right">
            <span className="glyphicon glyphicon-cog" onClick={this.showOptions}/>
              <span onclick={this.toggleActive} className={playClasses}/>
            </div>  
         </div>
        <div className="auditBox">
          {events}
        </div>
      </div>
    );
  }
});

var AuditEvent = React.createClass({
  getInitialState: function(){
    return { detailed: false };
  },
  
  render: function(){
    if(this.state.detailed){
      return this.renderDetailed();
    }else{
      return this.renderCompact();
    }
  },
  
  titleText: function(){
    var event = this.props.data;
    var text = event.action + " on ";
    var asset = event.asset;
    
    var id = asset == 'role' ? _.find(event.roles, function(r){ return r != event.conjur_role; }) : event.resources[0];
    return text + asset + " " + id;
  },
  
  renderDetailed: function(){
    return <div className="panel panel-info auditEvent">
      <div className="panel-heading">
        <strong className="panel-title">{this.titleText()}</strong>
        {this.toggleLink()}
      </div>
      <div className="panelBody">
        {this.detailText()}
      </div>
   </div>;
  },
  
  detailText: function(){
    var e = this.props.data;
    var children = _.flatten(
      _.keys(e).map(function(k){
        return [ <dt>{k}</dt>, <dd>{e[k]}</dd>, <br/> ];
      }));
    return <dl className="propertyList">{children}</dl>;
  },
  
  
  renderCompact: function(){
    return <div className="auditEvent alert alert-info">
      <strong>{this.titleText()}</strong>
      {this.toggleLink()}
    </div>;
  },
          
  toggleLink: function(){
    return <ToggleLink onChange={this.toggleDetail} data={this.state.detailed}/>    
  },
  
  toggleDetail: function(){
    this.setState({detailed: !this.state.detailed});
  }
});

var ToggleLink = React.createClass({
  render: function(){
    var up = this.props.data;
    var classes = React.addons.classSet({
      'glyphicon': true, 'pull-right': true, 
      'glyphicon-collapse-up': up,
      'glyphicon-collapse-down': !up
    });
    return <span className={classes} onClick={this.props.onChange}/>
  }
});


