# frozen_string_literal: true

source "https://rubygems.org/"

if RUBY_VERSION < "1.9"
  gem "hoe", "~> 3.20"
  gem "rake", "< 11"
  gem "rdoc", "< 4"

  gem "ruby-debug"
end

if RUBY_VERSION >= "2.0"
  if RUBY_ENGINE == "ruby"
    gem "simplecov", "~> 0.18"
    gem "byebug"
  end
end

if RUBY_VERSION >= "3.0"
  gem "standardrb"
  gem "fasterer"
end

gemspec

# vim: ft=ruby
