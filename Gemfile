# frozen_string_literal: true

# NOTE: This file is present to keep Travis CI happy. Edits to it will not
# be accepted.

source 'https://rubygems.org/'

if RUBY_VERSION < '1.9'
  gem 'rake', '< 11'
  gem 'rdoc', '< 4'
elsif RUBY_VERSION >= '2.0'
  if RUBY_ENGINE == 'ruby'
    gem 'coveralls', '~> 0.7'
    gem 'simplecov', '~> 0.7'
  end
end

gemspec

# vim: ft=ruby
