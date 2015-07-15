require 'conjur/dsl2/base'

module Conjur
  module DSL2
    # Abstract way to create anything.
    class Create < Base
      class CreateBase < Base
        attr_reader :kind, :id, :options

        def initialize(context, kind, id, options)
          super context
          @kind = kind
          @id = id
          @options = options
        end

        def valid?
          !id.blank? && !api.resource([ kind, id ].join(':')).exists?
        end

        def create_arguments
          [ id, options ]
        end

        def perform &block
          obj = api.send("create_#{kind}", *create_arguments)
          if block_given?
            require 'conjur/dsl2/annotations'
            context.with_handler Conjur::DSL2::Annotations, { obj: obj }, &block
          end
        end

        def undo
          raise "Create operations cannot be undone"
        end
      end

      class Host < CreateBase
        # signature is create_host(options)
        def create_arguments
          options[:id] = id
          [ options ]
        end
      end

      class Variable < CreateBase
        # signature is create_variable(mime_type, kind, options)
        def create_arguments
          mime_type = options.delete(:mime_type)
          kind = options.delete(:kind)
          options[:id] = id
          [ mime_type, kind, options ]
        end
      end

      def self.acts_as_createable kind
        klass = Class.new(CreateBase)
        const_set kind.to_s.capitalize, klass
      end

      [ :role, :resource, :user, :group, :layer ].each do |kind|
        acts_as_createable kind
      end

      def method_missing sym, *args, &block
        if dsl_method?(sym) && args.length >= 1
          # Add options Hash if it's missing
          args.push({}) if args.length == 1
          args.unshift sym
          args.unshift context
          Create.const_get(sym.to_s.capitalize).new(*args).perform &block
        else
          super
        end
      end

      def respond_to_missing? sym, include_all = false
        return dsl_method?(sym)
      end

      def dsl_method? sym
        Create.const_get(sym.to_s.capitalize)
      end
    end
  end
end
