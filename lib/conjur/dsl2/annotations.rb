require 'conjur/dsl2/base'

module Conjur
  module DSL2
    class Annotations < Base
      attr_reader :obj
      
      def method_missing sym, *args, &block
        if args.length == 1
          obj.annotations[sym.to_s] = args[0]
        else
          super
        end
      end
      
      def dsl_method?(sym)
        !self.class.instance_methods.include?(sym)
      end
    end
  end
end