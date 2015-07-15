module Conjur
  module DSL2
    class Context
      attr_reader :api, :script, :filename
  
      def initialize(api,script, filename = nil)
        @api = api
        @script = script
        @filename = filename
        @handlers = []
      end
      
      def method_missing sym, *args, &block
        if handler.dsl_method?(sym)
          handler.send sym, *args, &block
        else
          super
        end
      end

      def respond_to_missing? sym, include_all = false
        handler.dsl_method?(sym)
      end
      
      def handler
        @handlers.last
      end
      
      def execute handler
        args = [ @script ]
        args << @filename if @filename
        begin
          with_handler handler do
            instance_eval(*args)
          end
        rescue NameError
          # This is the place to catch syntax errors and report them
          # in a way that won't be so mysterious to users.
          raise $!
        end
      end
  
      def with_handler cls, attributes = {}, &block
        handler = cls.new(self)
        attributes.each do |k,v|
          handler.instance_variable_set "@#{k}", v
        end
        @handlers.push handler
        begin
          yield if block_given?
        ensure
          @handlers.pop
        end
      end
    end
  end
end
