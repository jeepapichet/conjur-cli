#
# Copyright (C) 2013 Conjur Inc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
module Conjur
  class Command
    extend IdentifierManipulation
    
    @@api = nil
    
    class << self
      attr_accessor :prefix
      def method_missing *a, &b
        Conjur::CLI.send *a, &b
      end

      def command name, *a, &block
        name = "#{prefix}:#{name}" if prefix
        Conjur::CLI.command(name, *a, &block)
      end

      def require_arg(args, name)
        args.shift or raise "Missing parameter: #{name}"
      end

      def api
        @@api ||= Conjur::Authn.connect
      end

      # Prevent a deprecated command from being displayed in the help output
      def hide_docs(command)
        def command.nodoc; true end
      end

      def acting_as_option(command)
        return if command.flags.member?(:"as-group") # avoid duplicate flags
        command.arg_name 'Perform all actions as the specified Group'
        command.flag [:"as-group"]

        command.arg_name 'Perform all actions as the specified Role'
        command.flag [:"as-role"]
      end
      
      def command_options_for_list(c)
        return if c.flags.member?(:role) # avoid duplicate flags
        c.desc "Role to act as. By default, the current logged-in role is used."
        c.flag [:role]
    
        c.desc "Full-text search on resource id and annotation values" 
        c.flag [:s, :search]
        
        c.desc "Maximum number of records to return"
        c.flag [:l, :limit]
        
        c.desc "Offset to start from"
        c.flag [:o, :offset]
        
        c.desc "Show only ids"
        c.switch [:i, :ids]
        
        c.desc "Show annotations in 'raw' format"
        c.switch [:r, :"raw-annotations"]
      end
      
      def command_impl_for_list(global_options, options, args)
        opts = options.slice(:search, :limit, :options, :kind) 
        opts[:acting_as] = options[:role] if options[:role]
        resources = api.resources(opts)
        if options[:ids]
          puts resources.map(&:resourceid)
        else
          resources = resources.map &:attributes
          unless options[:'raw-annotations']
            resources = resources.map do |r|
              r['annotations'] = (r['annotations'] || []).inject({}) do |hash, annot|
                hash[annot['name']] = annot['value']
                hash
              end
              r
            end
          end
          puts JSON.pretty_generate resources
        end
      end
        
      
      def display_members(members, options)
        result = if options[:V]
          members.collect {|member|
            {
              member: member.member.roleid,
              grantor: member.grantor.roleid,
              admin_option: member.admin_option
            }
          }
        else
          members.map(&:member).map(&:roleid)
        end
        display result
      end

      def display(obj, options = {})
        str = if obj.respond_to?(:attributes)
          JSON.pretty_generate obj.attributes
        elsif obj.respond_to?(:id)
          obj.id
        else
          JSON.pretty_generate obj
        end
        puts str
      end
    end
  end
end