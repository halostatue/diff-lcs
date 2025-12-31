require "rubygems"
require "rspec"
require "rspec/core/rake_task"
require "hoe"
require "rake/clean"
require "rdoc/task"

Hoe.plugin :halostatue
Hoe.plugin :rubygems

Hoe.plugins.delete :debug
Hoe.plugins.delete :newb
Hoe.plugins.delete :publish
Hoe.plugins.delete :signing

hoe = Hoe.spec "diff-lcs" do
  developer("Austin Ziegler", "halostatue@gmail.com")

  self.trusted_release = ENV["rubygems_release_gem"] == "true"

  require_ruby_version ">= 3.2.0", "< 5"

  self.licenses = ["MIT", "Artistic-1.0-Perl", "GPL-2.0-or-later"]

  spec_extras[:metadata] = ->(val) {
    val["rubygems_mfa_required"] = "true"
  }

  extra_dev_deps << ["hoe", "~> 4.0"]
  extra_dev_deps << ["hoe-halostatue", "~> 2.1", ">= 2.1.1"]
  extra_dev_deps << ["rspec", ">= 2.0", "< 4"]
  extra_dev_deps << ["rake", ">= 10.0", "< 14"]
  extra_dev_deps << ["rdoc", ">= 6.3.1", "< 7"]
  extra_dev_deps << ["simplecov", "~> 0.9"]
  extra_dev_deps << ["simplecov-lcov", "~> 0.9"]
  extra_dev_deps << ["standard", "~> 1.50"]
  extra_dev_deps << ["standard-thread_safety", "~> 1.0"]
  extra_dev_deps << ["fasterer", "~> 0.11"]
end

desc "Run all specifications"
RSpec::Core::RakeTask.new(:spec) do |t|
  rspec_dirs = %w[spec lib].join(":")
  t.rspec_opts = ["-I#{rspec_dirs}"]
end

namespace :spec do
  desc "Runs test coverage. Only works Ruby 2.0+ and assumes 'simplecov' is installed."
  task :coverage do
    Rake::Task["spec"].execute
  end
end

task coverage: "spec:coverage"
Rake::Task["spec"].actions.uniq! { |a| a.source_location }

task default: :spec unless Rake::Task["default"].prereqs.include?("spec")
task test: :spec unless Rake::Task["test"].prereqs.include?("spec")

task :version do
  require "diff/lcs/version"
  puts Diff::LCS::VERSION
end

RDoc::Task.new do |config|
  config.title = "diff-lcs"
  # config.main = "lib/diff/lcs.rb"
  config.main = "README.md"
  config.rdoc_dir = "doc"
  config.rdoc_files = hoe.spec.require_paths - ["Manifest.txt"] + hoe.spec.extra_rdoc_files
  config.markup = "markdown"
end
task docs: :rerdoc
