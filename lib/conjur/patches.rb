require 'conjur-api'

module Conjur
  class API
    def create_user(login, options = {})
      options = options.merge \
          cidr: [*options[:cidr]].map(&CIDR.method(:validate)).map(&:to_s) if options[:cidr]
      standard_create Conjur::Core::API.host, :user, nil, options.merge(login: login)
    end
    
    def create_group(id, options = {})
      standard_create Conjur::Core::API.host, :group, id, options
    end

    def create_host options = nil
      options = options.merge \
          cidr: [*options[:cidr]].map(&CIDR.method(:validate)).map(&:to_s) if options[:cidr]
      standard_create Conjur::Core::API.host, :host, nil, options
    end

    def create_layer(id, options = {})
      standard_create Conjur::API.layer_asset_host, :layer, id, options
    end
    
    def create_variable(mime_type, kind, options = {})
      standard_create Conjur::Core::API.host, :variable, nil, options.merge(mime_type: mime_type, kind: kind)
    end

    def create_host_factory(id, options = {})
      options = options.slice(:id, :layers, :ownerid)
      log do |logger|
        logger << "Creating host_factory #{id}"
        unless options.blank?
          logger << " with options #{options.to_json}"
        end
      end
      options ||= {}
      standard_create Conjur::API.host_factory_asset_host, 'host_factory', id, options
    end

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
      
      policy = <<-POLICY
- !#{type}
  id: #{PolicyHelper.role_id(id)}
      POLICY
      
      owner = options.delete(:ownerid)
      if owner
        $stderr.puts "Warning: owner #{owner} is specified, but ownership will be assigned to the policy #{PolicyHelper.policy_id id}"
        $stderr.puts "The owner will be the owner of the policy"
        owner_account, owner_kind, owner_id = owner.split(':', 3)
        if owner_account.nil?
          owner_id = owner_kind
          owner_kind = owner_account
          owner_account = Conjur.configuration.account
        end
        policy << "\n  owner: !role\n"
        policy << "    account: #{owner_account}\n"
        policy << "    kind: #{owner_kind}\n"
        policy << "    id: /#{owner_id}"
      end

      layers = options.delete(:layers)
      if layers
        policy << "\n  layers:"
        layers.each do |layer|
          layer_id = if layer.is_a?(Conjur::Layer)
            layer.id
          elsif layer.is_a?(String)
            layer
          else
            raise "Can't interpret layer #{layer}"
          end
          policy << "\n    - !layer #{layer_id.split('/')[1..-1].join('/')}"
        end
      end

      attributes = options.compact.stringify_keys.to_yaml.split("\n")[1..-1].join("\n  ")
      policy << "\n  #{attributes}"
      
      $stderr.puts policy

      response = load PolicyHelper.policy_id(id), policy

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
    # Set an annotation value.  This will perform an api call to set the annotation
    #   on the server.
    #
    # @param [String, Symbol] name the annotation name
    # @param [String] value the annotation value
    #
    # @return [String] the new annotation value
    def []= name, value
      update_annotation name.to_sym, value
      value
    end

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


