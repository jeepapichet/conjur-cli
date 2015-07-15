module Conjur
  module DSL2
    # Implements a DSL method handler. 
    #
    # The handler should implement the following method:
    #
    # +dsl_method?+ determines if a method, identified by a symbol, is a DSL method
    #
    # Each of these methods should have a corresponding method which performs the action.
    # Alternatively, the actions can be implemented by +method_missing+.
    #
    # If the action simply establishes a new context, it can call
    # +Context.with_handler+, with the class name of the new handler as well as 
    # the +block+ argument.
    class Base
      include IdentifierManipulation
      
      attr_reader :context
      
      def initialize(context)
        @context = context
      end
      
      def api; context.api; end
    end
  end
end
