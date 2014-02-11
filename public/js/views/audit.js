/** @jsx React.DOM */

function humanizeArray(array) {
  if (array.length == 0) {
    return "";
  }
  if (array.length == 1) {
    return array[0];
  }
  var slice = array.slice(0, -1);
  return slice.join(", ") + " and " + array[array.length - 1];
}

var AuditBox = React.createClass({
  getInitialState: function () {
    return {
      active: true,
      events: []
    };
  },

  componentWillMount: function () {
    var events = this.events = new AuditStream();
    var eventList = new AuditEventList().connect(events).on('change', function () {
      this.setState({events: eventList.events});
    }.bind(this));


    this.events = events;

    this.addStreams();

  },

  componentWillUnmount: function () {
    this.events.removeAll();
  },

  addStreams: function () {
    var events = this.events;
    (this.props.roles || []).forEach(events.addRole.bind(events));
    (this.props.resources || []).forEach(events.addResource.bind(events));
  },

  title: function () {
    var resources = this.props.resources || [];
    var roles = this.props.roles || [];
    console.log(resources, roles);
    var title = "Auditing ";
    if (resources.length) {
      title += "resource" + (resources.length == 1 ? '' : 's') + " " + humanizeArray(resources) + " ";
      if (roles.length) title += "and ";
    }
    if (roles.length) {
      title += "role" + (roles.length == 1 ? '' : 's') + " " + humanizeArray(roles) + " ";
    }

    return title;
  },

  render: function () {
    var events = this.state.events.map(function (e) {
      return <AuditEvent data={e}/>;
    });
    
    return (
      <div className="panel panel-default">
        <div className="panel-heading">
          <strong>{this.title()}</strong>
        </div>
        <div className="auditBox">
          <table className="table table-hover">
            <thead><tr><th className="when">When</th><th>What</th></tr></thead>
            <tbody> { events } </tbody>
          </table>
        </div>
      </div>
      );
  }
});

var AuditDetails = React.createClass({
  componentDidMount: function () {
    $(this.getDOMNode()).modal('show').on('hidden.bs.modal', function () {
      React.unmountComponentAtNode(document.getElementById('modal'));
    });
  },

  componentWillUnmount: function () {
    $(this.getDOMNode()).off('hidden.bs.modal');
  },

  render: function () {
    var html = {__html: '&times'}; // having this 'inline' makes my editor barf - jjm
    return ( <div className="modal fade bs-modal-lg">
      <div className="modal-dialog modal-lg">
        <div className="modal-content">
          <div className="modal-header">
            <button type="button" className="close" data-dismiss="modal" aria-hidden="true"
            dangerouslySetInnerHTML={html}/>
            <AuditDetailTitle data={this.props.data}/>
          </div>
          <div className="modal-body">
            <AuditDetailBody data={this.props.data}/>
          </div>
        </div>
      </div>
    </div>
      );
  }
});

AuditDetails.display = function (event) {
  React.renderComponent(
    <AuditDetails data={event}/>,
    document.getElementById('modal')
  );
};

var AuditDetailTitle = React.createClass({
  render: function () {
    return (<h4 className="modal-title">
      Event Details
    </h4>);
  }
});

var AuditDetailBody = React.createClass({
  render: function () {
    var e = _.clone(this.props.data);
    e.description = e.human;
    delete e.human;
    ['roles', 'resources', 'request_params'].forEach(function(k){
      e[k] = JSON.stringify(e[k]);
    });
    var children = _.flatten(
      _.keys(e).sort().map(function (k) {
        return [ <dt>{k}</dt>, <dd>{e[k]}</dd>, <br/> ];
      }));
    return <dl className="propertyList">{children}</dl>;
  }
});

var Timestamp = React.createClass({
  render: function () {
    var MILLIS_IN_SECOND = 1000;

    var date = new Date(this.props.timestamp * MILLIS_IN_SECOND);

    return this.transferPropsTo(
      <time dateTime={date.toISOString()} title={date.toString()}>{date.toRelativeTime()}</time>
    );
  }
});

var AuditEvent = React.createClass({
   render: function(){
     return (<tr onClick={this.handleClick}>
       <td> <Timestamp timestamp={this.props.data.timestamp}/> </td>
       <td> { this.props.data.human } </td>
     </tr>);
   },
  handleClick: function(){
    AuditDetails.display(this.props.data);
  }
});


var GlobalAudit = React.createClass({
  componentWillMount: function () {
    var stream = this.stream = new AuditStream();
    var events = this.events = new AuditEventList();

    stream.on('message', function (e) {
      events.push(JSON.parse(e.data));
    });

    events.on('change', function () {
      this.setState({events: events.events});
    }.bind(this));

    // Get *all* roles and resources, so we can audit *everything!*
    globalIds.roles(function (roles) {
      roles.forEach(function (roleId) {
        stream.addRole(roleId);
      })
    });
    globalIds.resources(function (resources) {
      resources.forEach(function (resourceId) {
        stream.addResource(resourceId);
      })
    });
  },

  getInitialState: function () {
    return { filters: [], events: [] }
  },

  render: function () {
    var events = this.state.events.map(function (e) {
      return <AuditEvent data={e}/>;
    });
    return <div className="panel panel-default">
      <div className="panel-heading">
        <strong>All Audit Events</strong>
      </div>
      <div className="auditBox">
         {events}
      </div>
    </div>
  }
});

