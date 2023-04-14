# frozen_string_literal: true

require 'thor'

require 'epp/render'
require_relative 'epp/version'

module Epp
  class Error < StandardError; end

  class CLI < Thor
    class_option :render_as, type: :string
    class_option :debug, type: :boolean
    class_option :verbose, type: :boolean

    desc 'dump', 'Outputs a dump of the internal template parse tree for debugging'
    def dump
      puts 'Not implemented'
    end

    desc 'render', 'Renders an EPP template as text'
    option :e, type: :string # inline template
    option :facts, type: :string
    option :header, type: :boolean
    option :node, type: :string
    option :values, type: :string
    option :values_file, type: :string
    def render(*files)
      if options[:e]
        template_options = Epp::InlineTemplateOptions.from_hash(options)
        template_options.epp_source = options[:e]

        puts Epp::Render.inline_epp(options[:node], options[:facts], template_options)
        return
      end

      if files.empty? && !$stdin.tty?
        template_options = Epp::InlineTemplateOptions.from_hash(options)
        template_options.epp_source = $stdin.read
        puts Epp::Render.inline_epp(options[:node], options[:facts], template_options)
        return
      end

      raise Puppet::Error, 'No input to process given on command line or stdin' if args.empty? && $stdin.tty?

      template_options = Epp::FileTemplateOptions.from_hash(options)
      template_options.files = files
      puts Epp::Render.file_epp(options[:node], options[:facts], template_options)
    end

    desc 'validate', 'Validate the syntax of one or more EPP templates'
    def validate
      puts 'Not implemented'
    end

    desc 'version', 'Print the version'
    def version
      puts Epp::VERSION
    end
  end
end
