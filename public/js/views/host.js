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
