module Conjur
  module Audit
    module Humanizer
      class << self
      # Add a "human" field to the event, describing what happened.
        def humanize event
          e = event.symbolize_keys
          # hack: sometimes resource is a hash.  We don't want that!
          if e[:resource] && e[:resource].kind_of?(Hash)
            e[:resource] = e[:resource]['id']
          end
          s = " #{e[:conjur_user]}"
          s << " (as #{e[:conjur_role]})" if e[:conjur_role] != e[:conjur_user]
          formatter = SHORT_FORMATS["#{e[:asset]}:#{e[:action]}"]
          if formatter
            s << " " << formatter.call(e)
          else
            s << " unknown event: #{e[:asset]}:#{e[:action]}!"
          end
          s << " (failed with #{e[:error]})" if e[:error]
          event['human'] = s
        end
        
        def append_features base
          base.class_eval do
            def humanize e
              Conjur::Audit::Humanizer.humanize e
            end
            def self.humanize e
              Conjur::Audit::Humanizer.humanize e
            end
          end
        end
        
        private
        SHORT_FORMATS = {
          'resource:check' => lambda{|e| "checked that they can #{e[:privilege]} #{e[:resource]} (#{e[:allowed]})" },
          'resource:create' => lambda{|e| "created resource #{e[:resource_id]} owned by #{e[:owner]}" },
          'resource:update' => lambda{|e| "gave #{e[:resource]} to #{e[:owner]}" },
          'resource:destroy' => lambda{|e| "destroyed resource #{e[:resource]}" },
          'resource:permit' => lambda{|e| "permitted #{e[:grantee]} to #{e[:privilege]} #{e[:resource]} (grant option: #{!!e[:grant_option]})" },
          'resource:deny' => lambda{|e| "denied #{e[:privilege]} from #{e[:grantee]} on #{e[:resource]}" },
          'resource:permitted_roles' => lambda{|e| "listed roles permitted to #{e[:permission]} on #{e[:resource]}" },
          'role:check' => lambda{|e| "checked that #{e[:role] == e[:conjur_user] ? 'they' : e[:role]} can #{e[:privilege]} #{e[:resource]} (#{e[:allowed]})" },
          'role:grant' => lambda{|e| "granted role #{e[:role]} to #{e[:member]} #{e[:admin_option] ? ' with ' : ' without '}admin" },
          'role:revoke' => lambda{|e| "revoked role #{e[:role]} from #{e[:member]}" },
          'role:create' => lambda{|e| "created role #{e[:role_id]}" }
        }

      end
    end
  end
end