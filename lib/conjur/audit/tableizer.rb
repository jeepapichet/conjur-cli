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
          result = if formatter
            formatter.call(e)
          else
            { }
          end
          result[:actor] = if e[:role] && e[:role] != e[:conjur_user]
            e[:role]
          else
            e[:conjur_user]
          end

          event['table'] = result
        end
        
        def append_features base
          base.class_eval do
            def humanize e
              Conjur::Audit::Tableizer.tableize e
            end
            def self.humanize e
              Conjur::Audit::Tableizer.tableize e
            end
          end
        end
        
        private
        
        INFO_FORMATS = {
          'resource:check'           => lambda{|e| { action: :check,      object_kind: :resource, object: e[:resource]    } },
          'resource:create'          => lambda{|e| { action: :create,     object_kind: :resource, object: e[:resource_id] } },
          'resource:update'          => lambda{|e| { action: :update,     object_kind: :resource, object: e[:resource]    } },
          'resource:destroy'         => lambda{|e| { action: :destroy,    object_kind: :resource, object: e[:resource]    } },
          'resource:permit'          => lambda{|e| { action: :permit,     object_kind: :resource, object: e[:resource]    } },
          'resource:deny'            => lambda{|e| { action: :deny,       object_kind: :resource, object: e[:resource]    } },
          'resource:permitted_roles' => lambda{|e| { action: :list_roles, object_kind: :resource, object: e[:resource]    } },
          'role:check'               => lambda{|e| { action: :check,      object_kind: :resource, object: e[:resource]    } },
          'role:grant'               => lambda{|e| { action: :grant,      object_kind: :role,     object: e[:role]        } },
          'role:revoke'              => lambda{|e| { action: :revoke,     object_kind: :role,     object: e[:role]        } },
          'role:create'              => lambda{|e| { action: :create,     object_kind: :role,     object: e[:role_id]     } }
        }
      end
    end
  end
end