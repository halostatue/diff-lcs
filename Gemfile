# NOTE: This file is not the canonical source of dependencies. Edit the
# Rakefile, instead.

source "https://rubygems.org/"

if ENV["DEV"]
  gem "debug", :platforms => [:mri]
end

if ENV["COVERAGE"] == "true"
  gem "simplecov", :require => false, :platforms => [:mri_34]
  gem "simplecov-lcov", :require => false, :platforms => [:mri_34]
end

if ENV["MAINTENANCE"] == "true"
  gem "standard", :require => false, :platforms => [:mri_34]
  gem "standard-thread_safety", :require => false, :platforms => [:mri_34]
  gem "fasterer", :require => false, :platforms => [:mri_34]
end

gemspec
