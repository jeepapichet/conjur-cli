/** @jsx React.DOM */

// Renders a permission as a tr
var PermissionRow = React.createClass({
  render: function(){
    var p = this.props.data;
    return (<tr>
        <td> { p.privilege } </td>
        <td> { p.grant_option ? "Yes" : "No" }</td>
        <td> <RoleLink id={p.grantor}/> </td>
      </tr>);
  }
})


var Permissions = React.createClass({
  getInitialState: function(){
    return {resources: [], loaded: false}
  },
  
  componentWillMount: function(){
    $.get(this.url(), function(data){
      this.setState({resources: data, loaded: true});
    }.bind(this));
  },
  
  render: function(){
    
    var rows = [];
    
    this.state.resources.forEach(function(r){
      var rowspan = r.permissions.length + 1;
      var parts = r.id.split(":");
      var id = parts[2];
      var kind = parts[1]; // ignore env?
      rows.push(
        <tr key={r.id}>
          <td rowSpan={rowspan}> <ResourceLink data={r.id}/> </td>,
          <td rowSpan={rowspan}>{ kind }</td>
        </tr>
      );
      if(rowspan == 1){
        rows.push(<td colSpan="3"> No Permissions </td>);
      }else{
        rows.push(r.permissions.map(function(p){
          return <PermissionRow data={p}/>
        }));
      }
    });
    
    rows = _.flatten(rows);
    return (<table className="table table-bordered">
        <thead>
          <tr>
            <th> Resource </th>
            <th> Kind </th>
            <th> Privilege </th>
            <th> Can Grant? </th>
            <th> Granted By </th>
          </tr>
        </thead>
        <tbody> {rows} </tbody>
      </table>
    );
  },
  
  url: function(){
    return "/api/authz/" + conjurConfiguration.account + "/resources?acting_as=" + this.props.role;
  }
})