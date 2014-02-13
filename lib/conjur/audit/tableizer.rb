module Conjur
  module Audit
    module Tableizer
      class << self
      # Output a standardized event suitable for table display.
        def tableize event
          e = event.symbolize_keys
          # hack: sometimes resource is a hash.  We don't want that!
          if e[:resource] && e[:resource].kind_of?(Hash)
            e[:resource] = e[:resource]['id']
          end
          
          formatter = INFO_FORMATS["#{e[:asset]}:#{e[:action]}"]
          info = if formatter
            formatter.call(e)
          else
            { }
          end
 
          result = {}
          result[:actor] = e[:conjur_role] || e[:conjur_user]
          result.merge! info
          event['table'] = result
        end
        
        def append_features base
          base.class_eval do
            def tableize e
              Conjur::Audit::Tableizer.tableize e
            end
            def self.humanize e
              Conjur::Audit::Tableizer.tableize e
            end
          end
        end
        
        private
        
        INFO_FORMATS = {
          'resource:check'           => lambda{|e| { action: :check,      object_kind: :resource, object: e[:resource], privilege: e[:privilege], result: e[:allowed] } },
          'resource:create'          => lambda{|e| { action: :create,     object_kind: :resource, object: e[:resource_id] } },
          'resource:update'          => lambda{|e| { action: :update,     object_kind: :resource, object: e[:resource]  } },
          'resource:destroy'         => lambda{|e| { action: :destroy,    object_kind: :resource, object: e[:resource]  } },
          'resource:permit'          => lambda{|e| { action: :permit,     object_kind: :resource, object: e[:resource], privilege: e[:privilege], grantee: e[:grantee], grant_option: e[:grant_option] } },
          'resource:deny'            => lambda{|e| { action: :deny,       object_kind: :resource, object: e[:resource], privilege: e[:privilege], grantee: e[:grantee] } },
          'resource:permitted_roles' => lambda{|e| { action: :list_roles, object_kind: :resource, object: e[:resource]  } },
          'role:check'               => lambda{|e| { action: :check,      object_kind: :resource, object: e[:resource], privilege: e[:privilege], detail: e[:allowed] } },
          'role:grant'               => lambda{|e| { action: :grant,      object_kind: :role,     object: e[:role],     member: e[:member], admin: e[:admin_option] } },
          'role:revoke'              => lambda{|e| { action: :revoke,     object_kind: :role,     object: e[:role],     member: e[:member] } },
          'role:create'              => lambda{|e| { action: :create,     object_kind: :role,     object: e[:role_id]     } }
        }
      end
    end
  end
end