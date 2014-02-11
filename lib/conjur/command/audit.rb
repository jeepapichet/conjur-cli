require 'conjur/command'
require 'active_support/ordered_hash'
require 'conjur/audit/follower'
require 'conjur/audit/humanizer'

class Conjur::Command
  class Audit < self
    include Conjur::Audit::Humanizer
    
    self.prefix = 'audit'
    
    class << self

      def short_event_format e
        s = "[#{Time.at(e['timestamp'])}] #{humanize(e)}"
      end
      
      def extract_int_option(source, name, dest=nil)
        if val = source[name]
          raise "Expected an integer for #{name}, but got #{val}" unless /\d+/ =~ val
          val.to_i.tap{ |i| dest[name] = i if dest }
        end
      end
      
      def extract_audit_options options
        # Do a little song and dance to simplify testing
        extracted = options.slice :follow, :short
        [:limit, :offset].each do |name|
            extract_int_option(options, name, extracted)
        end
        if extracted[:follow] && extracted[:offset]
            exit_now! "--offset option not allowed for --follow", 1
        end
        extracted
      end
      
      def show_audit_events events, options
        events.reverse!
        if options[:short]
          events.each{|e| puts short_event_format(e)}
        else
          puts JSON.pretty_generate(events)
        end
      end

      def audit_feed_command kind, &block
        command kind do |c|
          c.desc "Maximum number of events to fetch"
          c.flag [:l, :limit]

          c.desc "Offset of the first event to return"
          c.flag [:o, :offset]

          c.desc "Short output format"
          c.switch [:s, :short]
          
          c.desc "Follow events as they are generated"
          c.switch [:f, :follow]
          
          c.action do |global_options, options, args|
            options = extract_audit_options options
            if options[:follow]
              Conjur::Audit::Follower.new do |merge_options|
                instance_exec(args, options.merge(merge_options), &block)
              end.follow do |events|
                show_audit_events events, options
              end
            else
              show_audit_events instance_exec(args, options, &block), options
            end
          end
        end
      end
    end

    
    desc "Show audit events related to a role"
    arg_name 'role?'
    audit_feed_command :role do |args, options|
      if id = args.shift 
        method_name, method_args = :audit_role, [full_resource_id(id), options]
      else
        method_name, method_args = :audit_current_role, [options]
      end
      api.send method_name, *method_args
    end
    
    desc "Show audit events related to a resource"
    arg_name 'resource'
    audit_feed_command :resource do |args, options|
      id = full_resource_id(require_arg args, "resource")
      api.audit_resource id, options
    end
  end
end