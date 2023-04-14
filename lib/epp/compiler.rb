# frozen_string_literal: true

module Epp
  class Compiler
    def self.create(node, fact_file)
      # If no node is given, use the current node
      node ||= current_node

      unless node.is_a?(Puppet::Node)
        node = Puppet::Node.indirection.find(node)
        # Found node must be given the environment to use in some cases, use the one configured
        # or given on the command line
        node.environment = Puppet[:environment]
      end

      if fact_file
        given_facts = if fact_file.is_a?(Hash) # when used via the Face API
                        fact_file
                      elsif fact_file.end_with?('json')
                        Puppet::Util::Json.load(Puppet::FileSystem.read(fact_file, encoding: 'utf-8'))
                      else
                        Puppet::Util::Yaml.safe_load_file(fact_file)
                      end

        unless given_facts.instance_of?(Hash)
          raise "Incorrect formatted data in #{fact_file} given via the --facts flag"
        end

        # It is difficult to add to or modify the set of facts once the node is created
        # as changes does not show up in parameters. Rather than manually patching up
        # a node and risking future regressions, a new node is created from scratch
        node = Puppet::Node.new(node.name,
                                facts: Puppet::Node::Facts.new('facts', node.facts.values.merge(given_facts)))
        node.environment = Puppet[:environment]
        node.merge(node.facts.values)
      end

      compiler = Puppet::Parser::Compiler.new(node)
      # configure compiler with facts and node related data
      # Set all global variables from facts
      compiler.send(:set_node_parameters)

      # pretend that the main class (named '') has been evaluated
      # since it is otherwise not possible to resolve top scope variables
      # using '::' when rendering. (There is no harm doing this for the other actions)
      #
      compiler.topscope.class_set('', compiler.topscope)
      compiler
    end

    # private

    # Returns the current Puppet node
    # @return [Puppet::Node] the current node
    def self.current_node
      node = Puppet[:node_name_value]

      # If we want to lookup the node we are currently on
      # we must returning these settings to their default values
      Puppet.initialize_settings([], true)
      Puppet.settings[:facts_terminus] = 'facter'
      Puppet.settings[:node_cache_terminus] = nil

      node
    end
  end
end
