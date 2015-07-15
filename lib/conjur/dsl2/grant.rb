require 'conjur/dsl2/members'

module Conjur
  module DSL2
    # Abstract way to grant any role.
    #
    # This method expects to be invoked with the following signature:
    #    <kind> <role-id> <member-id>
    #
    # For example:
    #   group 'developers', 'user:alice'
    #   role  'group:developers', 'user:alice'
    class Grant < Base
      include Conjur::DSL2::Members::MembersHandler
      
      class GrantBase < Conjur::DSL2::Members::KindOperation
        def perform
          subject_role.grant_to member_role
        end
        
        def undo
          subject_role.revoke_from member_role
        end
      end
      
      class Role < GrantBase
      end
      
      def self.acts_as_role kind
        klass = Class.new(GrantBase) do
          def subject_role
            api.role([kind, role].join(':'))
          end
        end
        const_set kind.to_s.capitalize, klass
      end

      [ :user, :group, :host, :layer ].each do |kind|
        acts_as_role kind
      end
    end
  end
end