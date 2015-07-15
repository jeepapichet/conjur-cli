module Conjur
  module DSL3
    module Types
      class Deny
        include Base
        
        register_yaml_type 'deny'
        register_yaml_field 'member', Member
        
        resources :resource
        strings   :privilege
        members   :member
      end
    end
  end
end
