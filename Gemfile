# NOTE: This file is not the canonical source of dependencies. Edit the
# Rakefile, instead.

source "https://rubygems.org/"

gem "debug", platforms: [:mri_31]

if RUBY_VERSION.start_with?("3.")
  gem "standard"
  gem "standard-thread_safety"
  gem "fasterer"
end

gemspec
