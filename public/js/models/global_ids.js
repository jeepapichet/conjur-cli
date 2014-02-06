/**
 * Abstract base for a list of all roles or resources.
 * 
 * @param fetch function taking a callback to be called with a list
 *  of members once they are fetched.  This function will only be
 *  called once.
 */
var GlobalList = function(fetch){
  this._fetch = fetch;
  this._members = null;
  this._fetching = false;
  this._callbacks = [];
};

/**
 * Pass memebers to callback as soon as they are available.
 * @param callback function taking a list of members as an argument.
 * @returns {boolean} true if callback was called synchronously.
 */
GlobalList.prototype.members = function(callback){
  if(this._members){
    callback(this._members);
    return true;
  }
  this._callbacks.push(callback);
  if(!this._fetching){
    this._fetching = true;
    this._fetch(function(result){
      this._fetching = false;
      this._members = _.uniq(result);
      console.log('set members to ', this._members);
      this._callbacks.forEach(function(cb){
        cb.call(null, this._members);
      }.bind(this));
    }.bind(this));
  }
  return false;
}

/**
 * Provides a list of all role and resource ids visible to 
 * the current role.
 * @constructor
 */
var GlobalIds = function(){
  var authzUrl = '/api/authz/' + conjurConfiguration.account;
  var roles = new GlobalList(function(callback){
    $.get( authzUrl + '/roles/user/' + conjurConfiguration.login + '?all', callback );
  });
  
  var resources = new GlobalList(function(callback){
    $.get(authzUrl + '/resources', function(data){
      callback(_.map(data, function(o){ return o.id; }));
    });
  });
  
  this.roles = function(cb){ return roles.members(cb); };
  this.resources = function(cb){ return resources.members(cb); };
};
