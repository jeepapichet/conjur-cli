require 'conjur-api'

module Conjur
  class API
    def load id, policy, method: :post
      log do |logger|
        logger << "Loading policy #{id}:\n#{policy}"
      end

      v6_url = URI.join(Conjur.configuration.appliance_url, '/api/v6')
      JSON.parse Resource.new(v6_url, credentials)["policies/cucumber/policy/#{id}"].send(method, policy)
    end
  end

  module PolicyHelper
    class << self
      def policy_id identifier
        if identifier.index('@')
          identifier.split('@')[1]
        else
          identifier.split('/')[0...-1].join('/')
        end
      end

      def role_id identifier
        if identifier.index('@')
          identifier.split('@')[0]
        else
          identifier.split('/').last
        end
      end
    end
  end


  module StandardMethods
    include PolicyHelper
    
    protected

    # @api private
    #
    # Create this resource by sending a POST request to its URL.
    #
    # @param [String] host the url of the service (for example, https://conjur.host.com/api)
    # @param [String] type the asset `kind` (for example, 'user', 'group')
    # @param [String, nil] id the id of the new asset
    # @param [Hash] options options to pass through to `RestClient::Resource`'s `post` method.
    # @return [Object] an instance of a class determined by `type`.  For example, if `type` is
    #   `'user'`, the class will be `Conjur::User`.
    def standard_create(host, type, id = nil, options = nil)
      id = options.delete(:id) unless id
      id = options.delete(:login) unless id

      raise "id is required" unless id

      log do |logger|
        logger << "Creating #{type}"
        logger << " #{id}" if id
        unless options.blank?
          logger << " with options #{options.to_json}"
        end
      end

      if owner = options.delete(:ownerid)
        $stderr.puts "Warning: owner #{owner} is specified, but ownership will be assigned to the policy #{PolicyHelper.policy_id id}"
      end

      attributes = options.compact.stringify_keys.to_yaml.split("\n")[1..-1].join("\n  ")

      response = load PolicyHelper.policy_id(id), <<-POLICY
- !#{type}
  id: #{PolicyHelper.role_id(id)}
  #{attributes}
      POLICY

      api_key = (response['created_roles']["#{Conjur.configuration.account}:#{type}:#{id}"]||{})['api_key']

      send(type, id).tap do |obj|
        obj.attributes['api_key'] = api_key if api_key
      end
    end
  end

  module PathBased
    def role_yaml
      if %w(user group host layer).member?(kind.to_s)
        <<-ROLE
!#{kind}
    id: #{PolicyHelper.role_id id}
    account: #{account}
        ROLE
      else
        <<-ROLE
!role
    #{yaml_fields indentation: 4}
        ROLE
      end
    end

    def policy_id
      PolicyHelper.policy_id identifier
    end

    def yaml_fields options = {}
      indentation = options.delete(:indentation) || 2
      {
        account: account,
        kind: kind,
        id: PolicyHelper.role_id(identifier)
      }.merge(options.compact).stringify_keys.to_yaml(indentation: indentation).split("\n")[1..-1].join("\n" + (" " * indentation))
    end
  end

  class Annotations
    protected

    def update_annotation name, value
      @resource.invalidate do
        @annotations_hash = nil

        @resource.conjur_api.load(@resource.policy_id, <<-POLICY)
- !resource
  #{@resource.yaml_fields annotations: { name.to_s => value } }
        POLICY
      end
    end
  end

  class Resource
    # @api private
    def create(options = {})
      log do |logger|
        logger << "Creating resource #{resourceid}"
        unless options.empty?
          logger << " with options #{options.to_json}"
        end
      end

      if owner = options.delete(:acting_as)
        $stderr.puts "Warning: owner #{owner} is specified, but ownership will be assigned to the policy #{policy_id}"
      end

      conjur_api.load(policy_id, <<-POLICY)
- !resource
  #{yaml_fields}
      POLICY
    end

    def permit(privilege, role, options = {})
      raise "grant_option is not supported for Conjur Policy API v6" if options && options[:grant_option]

      role = conjur_api.role(role) unless role.is_a?(Conjur::Role)

      eachable(privilege).each do |p|
        log do |logger|
          logger << "Permitting #{p} on resource #{resourceid} by #{role.roleid}"
          unless options.empty?
            logger << " with options #{options.to_json}"
          end
        end

        conjur_api.load(policy_id, <<-POLICY)
- !permit
  resource: !resource
    #{yaml_fields indentation: 4}
  privilege: #{privilege}
  role: #{role.role_yaml}
        POLICY
      end
      nil
    end
  end

  class Role
    def create(options = {})
      log do |logger|
        logger << "Creating role #{roleid}"
        unless options.empty?
          logger << " with options #{options.to_json}"
        end
      end

      if owner = options.delete(:acting_as)
        $stderr.puts "Warning: owner #{owner} is specified, but ownership will be assigned to the policy #{policy_id}"
      end

      conjur_api.load(policy_id, <<-POLICY)
- !role
  #{yaml_fields}
      POLICY
    end

    def grant_to(member, options={})
      raise "admin_option is not supported for Conjur Policy API v6" if options && options[:admin_option]

      log do |logger|
        logger << "Granting role #{identifier} to #{cast(member, :roleid)}"
        unless options.blank?
          logger << " with options #{options.to_json}"
        end
      end
      member = conjur_api.role(member) unless member.is_a?(Conjur::Role)

      conjur_api.load(policy_id, <<-POLICY)
- !grant
  role: !role
    #{yaml_fields indentation: 4}
  member: #{member.role_yaml}
      POLICY
    end
  end
end


