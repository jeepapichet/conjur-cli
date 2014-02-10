/** @jsx React.DOM */

var Variable = React.createClass({
  render: function() {
    var updaters = this.props.data.updaters.map(function (member) {
      return <li>
        <RoleLink id={member} />
      </li>
    }.bind(this));
    var fetchers = this.props.data.fetchers.map(function (member) {
      return <li>
        <RoleLink id={member} />
      </li>
    }.bind(this));
    var resourceId = [ conjurConfiguration.account, 'variable', this.props.data.variable.id ].join(':')
    return (
      <div className="variable">
        <h2>Variable {this.props.data.variable.identifier}</h2>
        <dl>
          <dt>Owner</dt>
          <dd><RoleLink id={this.props.data.variable.ownerid}/></dd>
          <dt>Updaters</dt>
          <dd>
            <ul>
              {updaters}
            </ul>
          </dd>
          <dt>Fetchers</dt>
          <dd>
            <ul>
              {fetchers}
            </ul>
          </dd>
        </dl>
        <div className="audit auditVariable">
          <AuditBox resources={[resourceId]}/>
        </div>
      </div>
    );
  }
});
