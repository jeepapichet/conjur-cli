/** @jsx React.DOM */
  
// render a <time> tag. props.timestamp should be a timestamp
// that moment can parse, props.format should be one of the
// format strings accepted by moment (optional).
var Time = React.createClass({
  render: function(){
    var timestamp = this.props.timestamp;
    var format = this.props.format || 'lll';
    var m = moment(timestamp);
    
    return <time datetime={m.format()}>{m.format(format)}</time>;
  }
})