module Conjur
  module DSL3
    module Types
      class Permissions
        include Base

        register_yaml_type 'permissions'
        
        resources :resource
        strings   :privilege
        members   :member
      end
    end
  end
end
