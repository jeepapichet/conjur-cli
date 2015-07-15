module Conjur
  module DSL3
    module Types
      class Members
        include Base
        
        register_yaml_type 'members'
        
        roles   :role
        members :member
      end
    end
  end
end
