create do
  group 'developers'
  user 'joe'
end

annotate do
  group 'developers' do
    {
      name: developers
      'path/like': value
    }
  end

  user 'joe' do
    {
      name: 'developers'
    }
  end
end
  
grant do
  {
    role: group 'developers'
    to: user 'joe',
    admin: true
  }
  
  {
    role: group 'developers',
    to: group 'ops'
  }
end

revoke do
  {
    role: group 'security_admin',
    from: user 'joe'
  }
end
   
permit do
  {
    role: group 'developers',
    privilege: 'read',
    resource: group 'developers'  
  }
  {
    role: group 'ops',
    privilege: [ 'read', 'update' ],
    resource: group 'developers'  
  }
end