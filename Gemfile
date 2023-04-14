# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in epp.gemspec
gemspec

group :development do
  gem 'fuubar'

  gem 'pry'
  gem 'pry-stack_explorer'

  gem 'yard'
end

group :test do
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.0'
  gem 'rspec-collection_matchers', '~> 1.0'

  gem 'rubocop', '~> 1.48', require: false
  gem 'rubocop-performance', '~> 1.16', require: false
  gem 'rubocop-rspec', '~> 2.19', require: false
end
