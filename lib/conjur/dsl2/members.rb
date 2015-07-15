require 'conjur/dsl2/base'

module Conjur
  module DSL2
    # Handler class which
    class Members < Base
      # Mixin module for sub-handlers which perform member operations (grant & revoke).
      module MembersHandler
        def method_missing sym, *args, &block
          if dsl_method?(sym) && args.length == 2
            args.unshift sym
            args.unshift context
            self.class.const_get(sym.to_s.capitalize).new(*args).perform &block
          else
            super
          end
        end

        def respond_to_missing? sym, include_all = false
          return super || dsl_method?(sym)
        end

        def dsl_method? sym
          self.class.const_get(sym.to_s.capitalize)
        end
      end

      # Base class for handlers which implement grant/revoke for a specific
      # kind (host, role, user, layer, etc).
      class KindOperation < Base
        attr_reader :kind, :role, :member
        
        def initialize(context, kind, role, member)
          super context
          @kind = kind
          @role = role
          @member = member
        end
        
        def subject_role
          api.role(role)
        end

        def member_role
          api.role(member)
        end

        def valid?
          # TODO: check that the current role has permission to do this
          subject_role.exists? && member_role.exists?
        end
      end

      def dsl_method?(sym)
        %w(grant revoke).member?(sym.to_s)
      end

      def grant &block
        require 'conjur/dsl2/grant'
        context.with_handler Conjur::DSL2::Grant, &block
      end

      def revoke
        require 'conjur/dsl2/revoke'
        context.with_handler Conjur::DSL2::Revoke, &block
      end
    end
  end
end
