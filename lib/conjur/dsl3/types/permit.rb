module Conjur
  module DSL3
    module Types
      class Permit
        include Base
        
        register_yaml_type 'permit'
        register_yaml_field 'member', Member
        
        resources :resource
        strings   :privilege
        members   :member
      end
    end
  end
end
