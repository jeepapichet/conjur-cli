/** @jsx React.DOM */

/**
 Renders a link to the resource with id given by this.props.data.
 
 Includes a slick little icon for the following kinds:
  TODO which kinds? 
**/
var ResourceLink = React.createClass({
  render: function(){
    var resourceId = this.props.data;
    var tokens = resourceId.split(':');
    var kind = tokens[1];
    var id = tokens[tokens.length - 1];
    var href = "/ui/" + kind + "s/" + encodeURIComponent(id);
    return <a className={[kind, 'resource-link'].join(' ')} href={href}>{id}</a>
  }
});
