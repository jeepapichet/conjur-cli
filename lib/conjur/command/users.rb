require 'conjur/authn'
require 'conjur/command'

class Conjur::Command::Users < Conjur::Command
  self.prefix = :user
  
  desc "Create a new user"
  arg_name "login"
  command :create do |c|
    c.desc "Prompt for a password for the user"
    c.switch [:p,:password]
    
    acting_as_option(c)
    
    c.action do |global_options,options,args|
      login = require_arg(args, 'login')
      
      opts = options.slice(:ownerid)
      if options[:p]

        # use stderr to allow output redirection, e.g.
        # conjur user:create -p username > user.json
        hl = HighLine.new($stdin, $stderr)

        password = hl.ask("Enter the password (it will not be echoed): "){ |q| q.echo = false }
        confirmation = hl.ask("Confirm the password: "){ |q| q.echo = false }
        
        raise "Password does not match confirmation" unless password == confirmation
        
        opts[:password] = password
      end
      
      display api.create_user(login, opts)
    end
  end
end