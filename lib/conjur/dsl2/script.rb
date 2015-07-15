require 'conjur/dsl2/base'

module Conjur
  module DSL2
    # Implements the base script functions: create, members, and permissions.
    class Script < Base
      def execute
        context.execute self.class
      end

      def create &block
        require 'conjur/dsl2/create'
        context.with_handler Conjur::DSL2::Create, &block
      end
      
      def members &block
        require 'conjur/dsl2/members'
        context.with_handler Members, &block
      end
      
      def permissions &block
        raise "Not implemented"
      end
      
      def dsl_method?(sym)
        %w(create members permissions).member?(sym.to_s)
      end
    end
  end
end
