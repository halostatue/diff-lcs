# frozen_string_literal: true

# NOTE: This file is present to keep Travis CI happy. Edits to it will not
# be accepted.

source 'https://rubygems.org/'

if RUBY_VERSION < '1.9'
  gem 'hoe', '~> 3.20'
  gem 'rake', '< 11'
  gem 'rdoc', '< 4'

  gem 'ruby-debug'
elsif RUBY_VERSION >= '2.0'
  if RUBY_ENGINE == 'ruby'
    gem 'simplecov', '~> 0.18'

    gem 'byebug'

    if RUBY_VERSION >= '2.6'
      gem 'sorbet'
    end
  end
end

gemspec

# vim: ft=ruby
