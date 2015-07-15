module Conjur
  module DSL3
    module Types
      module ActsAsResource
        def self.included(base)
          base.include Base
          
          base.module_eval do
            attr_accessor :id
            attr_accessor :annotations
            
            register_yaml_field 'annotations', Hash
            
            def resource?
              true
            end
          end
        end
      end
      
      module ActsAsRole
        def self.included(base)
          base.include Base
          
          base.module_eval do
            def role?
              true
            end
          end
        end
      end
      
      class Role
        include ActsAsRole
        
        string :kind
        string :id
        
        register_yaml_type 'role'
      end
      
      class Resource
        include ActsAsResource

        string :kind
        string :id
        
        register_yaml_type 'resource'
      end
      
      class User
        include ActsAsResource
        include ActsAsRole
        
        register_yaml_type 'user'
      end
      
      class Group
        include ActsAsResource
        include ActsAsRole

        register_yaml_type 'group'
      end
      
      class Host
        include ActsAsResource
        include ActsAsRole
        
        register_yaml_type 'host'
      end
      
      class Layer
        include ActsAsResource
        include ActsAsRole
        
        register_yaml_type 'layer'
      end
      
      class Variable
        include ActsAsResource
        
        register_yaml_type 'variable'
      end
      
      class Webservice
        include ActsAsResource

        register_yaml_type 'webservice'
      end
    end
  end
end
