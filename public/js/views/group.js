/** @jsx React.DOM */

var Group = React.createClass({
  render: function() {
    var members = this.props.data.members.map(function (member) {
      return <li>
        <RoleLink data={member} />
      </li>
    }.bind(this));

    return (
      <div className="group">
        <h1>Group {this.props.data.group.id}</h1>
        <dl>
          <dt>Owner</dt>
          <dd>{this.props.data.group.ownerid}</dd>
          <dt>Members</dt>
          <dd>
            <ul>
              {members}
            </ul>
          </dd>
        </dl>
        <figure/>
      </div>
    );
  },

  componentDidMount: function(rootNode) {
    var figure = rootNode.getElementsByTagName("figure")[0];
    var sigInst = sigma.init(figure);

    sigInst.addNode('group',{
      label: this.props.data.group.id,
      x: 1,
      y: 0.8
    }).graphProperties({
      minNodeSize: 1,
      maxNodeSize: 10,
      minEdgeSize: 3
    });

    var i = 0, members = this.props.data.members;
    var dx = 0, sx = 1;

    if (members.length > 1) {
      dx = 1 / (members.length - 1);
      sx = 0.5;
    }

    members.forEach(function (member) {
      var member_id = member.member;

      sigInst.addNode(member_id, {
        label: member_id,
        x: sx + i * dx,
        y: 1.2
      })
      .addEdge(i++ + "", 'group', member_id);
    }.bind(this));

    sigInst.draw(2,2,2);
  }
});
