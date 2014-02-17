/** @jsx React.DOM */
  
/** render a link to the role represented by this.props.id
   Example: <RoleLink id="ci:user:jon"/>
*/
var RoleLink = React.createClass({
  render: function() {
    var tokens = this.props.id.split(":");
    var kind = tokens[1];
    var id = tokens[tokens.length-1];
    var href = "/ui/" + kind + "s/" + encodeURIComponent(id);
    return <a className={[kind, 'role-link'].join(' ')} href={href}>
        {id}
      </a>;
  }
});
