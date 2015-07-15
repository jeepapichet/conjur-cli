module Conjur
  module DSL3
    module Types
      class Revoke
        include Base
        
        register_yaml_type 'revoke'

        role   :role
        member :member
      end
    end
  end
end

