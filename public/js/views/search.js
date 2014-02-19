/**@jsx React.DOM*/
var SearchForm = React.createClass({
  render: function(){
    return ( 
    <form className="form-inline navbar-form" role="search" onSubmit={this.handleSubmit}>
      <div className="form-group">
        <input ref="input" type="text" className="form-control" placeholder="Search Resources"></input>
       </div>
      <button type="submit" className="btn btn-default search-button">Search</button>
    </form>
    );
  },
  
  handleSubmit: function(e){
    var search = this.refs.input.getDOMNode().value;
    if(search && search.length != 0){
      router.navigate("/ui/search/" + encodeURIComponent(search), {trigger: true});
    }
    return false;
  }
});


var SearchResults = React.createClass({
  render: function(){
    console.log("SearchResults.data=",this.props.data);
    var results = this.props.data.results.map(function(resource){
      return <tr>
        <td> <ResourceLink data={resource.id}/> </td>
        <td> <RoleLink id={resource.owner}/> </td>
      </tr>
    });
    var heading = "Found " + this.props.data.results.length + 
      " resources matching \"" + this.props.data.search + "\"";
    return (<div className="search"> 
      <h3> { heading } </h3>
      <div className="search-results">
        <table className="table">
          <thead>
            <th>Resource</th>
            <th>Owner</th>
          </thead>
          <tbody>
            {results}
          </tbody>
        </table>
      </div>
    </div>);
  }
});

SearchResults.search = function(search, container){
  container = container || document.getElementById('content');
  $.get(endpoints.authz("resources", {search: search}), function(results){
    
    var data = {search: search, results: results};
    React.renderComponent(<SearchResults data={data}/>, container);
  });
}

