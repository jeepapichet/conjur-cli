module Conjur
  module DSL3
    module Types
      class Grant
        include Base
        
        register_yaml_type 'grant'

        roles   :role
        members :member
      end
    end
  end
end

