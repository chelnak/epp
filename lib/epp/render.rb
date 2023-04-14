# frozen_string_literal: true

require 'puppet'
require_relative 'compiler'

module Epp

  class TemplateOptions;end

  class InlineTemplateOptions < TemplateOptions
    attr_accessor :epp_source, :values, :values_file

    def initialize(epp_source = '', values, values_file)
      @epp_source = epp_source
      @values = values
      @values_file = values_file
    end

    def self.from_hash(hash)
      new(hash[:values], hash[:values_file])
    end
  end

  class FileTemplateOptions < TemplateOptions
    attr_accessor :files, :values, :values_file, :header

    def initialize(files = [], values, values_file, header)
      @files = files
      @values = values
      @values_file = values_file
      @header = header
    end

    def show_filename?
      @files.count > 1
    end


    def self.from_hash(hash)
      new(hash[:values], hash[:values_file], hash[:header])
    end
  end

  class Render
    def self.inline_epp(node, facts, options)

      raise Puppet::Error, "Invalid template options" unless options.is_a?(Epp::InlineTemplateOptions)

      compiler = Epp::Compiler.create(node, facts)
      compiler.with_context_overrides('For rendering inline epp') do
        render_inline(compiler, options)
      end
    end

    def self.file_epp(node, facts, options)

      raise Puppet::Error, "Invalid template options" unless options.is_a?(Epp::FileTemplateOptions)

      compiler = Epp::Compiler.create(node, facts)
      compiler.with_context_overrides('For rendering epp file') do
        output = []
        options.files.each_with_index do |file, i|
          output.append(render_file(compiler, file, options, i))
        rescue Puppet::ParseError => e
          raise Puppet::Error, e.message
        end
        output.join
      end
    end

    # private

    def self.render_file(compiler, file, options, _file_nbr)
      template_args = get_values(compiler, options.values, options.values_file)

      output = []
      begin
        output.append("--- #{file}\n") if options.show_filename? && options.header

        # Change to an absolute file only if reference is to a an existing file. Note that an absolute file must be used
        # or the template must be found on the module path when calling the epp evaluator.
        template_file = Puppet::Parser::Files.find_template(file, compiler.environment)
        if template_file.nil? && Puppet::FileSystem.exist?(file)
          file = File.expand_path(file)
        end

        result = Puppet::Pops::Evaluator::EppEvaluator.epp(compiler.topscope, file, compiler.environment,
                                                           template_args)
        if result.instance_of?(Puppet::Pops::Types::PSensitiveType::Sensitive)
          output.append(result.unwrap)
        else
          output.append(result)
        end
      rescue Puppet::ParseError => e
        Puppet.err("--- #{file}") if options.show_filename?
        raise e
      end
      output.append("\n") # not great but ok for now
      output.join
    end

    def self.render_inline(compiler, options)
      template_args = get_values(compiler, options.values, options.values_file)
      begin
        result = Puppet::Pops::Evaluator::EppEvaluator.inline_epp(compiler.topscope, options.epp_source, template_args)
        if result.instance_of?(Puppet::Pops::Types::PSensitiveType::Sensitive)
          result.unwrap
        else
          result
        end
      rescue Puppet::ParseError => e
        Puppet.err("--- #{options.epp_source}")
        raise e
      end
    end

    def self.validate_values(values)
      unless values.nil? || values.is_a?(Hash)
        Puppet.err("Values must evaluate to a Hash or undef/nil, got: '#{values.class}'")
      end
    end

    def self.get_values(compiler, values, values_file)
      template_values = nil

      if values_file
        template_values = values_from_file(compiler, values_file)
      end

      if values
        inline_values = values_from_hash(compiler, values)
        template_values = template_values.nil? ? inline_values : template_values.merge(inline_values)
      end

      validate_values(template_values)

      template_values
    end

    def self.values_from_file(compiler, values_file)
      template_values = nil

      case values_file
      when /\.yaml$/
        template_values = Puppet::Util::Yaml.safe_load_file(values_file, [Symbol])
      when /\.pp$/
        evaluating_parser = Puppet::Pops::Parser::EvaluatingParser.new
        template_values = evaluating_parser.evaluate_file(compiler.topscope, values_file)
      else
        raise Puppet::Error, 'Only .yaml or .pp can be used as a --values_file'
      end

      template_values
    end

    def self.values_from_hash(compiler, values)
      evaluating_parser = Puppet::Pops::Parser::EvaluatingParser.new
      evaluating_parser.evaluate_string(compiler.topscope, values, 'values-hash')
    end
  end
end
