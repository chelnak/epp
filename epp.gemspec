# frozen_string_literal: true

require_relative 'lib/epp/version'

Gem::Specification.new do |spec|
  spec.name = 'epp'
  spec.version = Epp::VERSION
  spec.authors = ['Craig Gumbley']
  spec.email = ['info@puppet.com']

  spec.summary = 'Render EPP templates'
  spec.description = 'Render EPP templates'
  spec.homepage = 'https://github.com/puppetlabs/epp'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  spec.files = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'bin/**/*',
    'spec/**/*',
    'exe/**/*',
  ]

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'puppet', '~> 7.0'
  spec.add_dependency 'thor', '~> 1.2'
end
