module Conjur
  module DSL
    attr_reader :data
    
    class YAMLBase
      attr_reader :id, :owns
      
      def initialize data
        raise "#{self.class.name.split('::').last} requires data" if data.blank?
        @data = data
      end
      
      def kind
        self.class.name[4..-1].downcase
      end
      
      def validate; true; end
        
      def perform runner
      end
    end
    
    class YAMLGroup < YAMLBase
      def perform document, runner
        runner.group id do
          document.perform runner, self.owns
        end
      end
    end

    class YAMLPolicy < YAMLBase
      attr_reader :version
      
      def perform document, runner
        runner.policy [ id, version ].join('-') do
          document.perform runner, self.owns
        end
      end
    end

    class YAMLVariable < YAMLBase
    end

    class YAMLRole < YAMLBase
    end

    class YAMLWebService < YAMLBase
      
      # This is kind of weird actually
      # My example YAML loads permissions as a Hash with one entry, whose key is a 
      # Hash of [ execute, read ] => *secrets
      def permissions
        (@permissions||{}).keys[0]
      end
    end

    class YAMLLayer < YAMLBase
    end
    
    class YAMLRunner
      attr_reader :doc
      
      def initialize source
        YAML.add_tag("!group", YAMLGroup)
        YAML.add_tag("!policy", YAMLPolicy)
        YAML.add_tag("!role", YAMLRole)
        YAML.add_tag("!variable", YAMLVariable)
        YAML.add_tag("!webservice", YAMLWebService)
        YAML.add_tag("!layer", YAMLLayer)
        
        @doc = YAML.load(source)
        @objects = {}
      end

      def validate
        process_each @doc do |item|
          item.validate
        end
      end
      
      def perform runner, record = :doc
        record = @doc if record == :doc
        if record.is_a?(YAMLBase)
          process_item record do |child|
            child.perform self, runner
          end
        else
          perform_children record, runner
        end
      end

      def perform_children item, runner
        process_each item do |child|
          child.perform self, runner
        end
      end
      
      def item_exists? item
        !lookup_item(item).nil?
      end
      
      def lookup_item item
        @objects[[obj.kind, obj.id]] = obj
      end
      
      def register_object obj
        @objects[[obj.resource.kind, obj.id]] = obj
      end
      
      protected
      
      def process_each item, &block
        if item.respond_to?(:each)
          item.each do |k,v|
            # If v is nil, an array is being iterated and the value is k. 
            # If v is not nil, a hash is being iterated and the value is v.
            value = v || k

            if value.is_a?(YAMLBase)
              process_item value, &block
            else
              process_each value, &block
            end
          end
        end
      end
      
      def process_item item, &block
        block.call(item)
      end
    end
  end
end