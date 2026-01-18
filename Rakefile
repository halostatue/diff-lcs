require "rubygems"
require "rspec"
require "rspec/core/rake_task"
require "hoe"
require "rake/clean"
require "rdoc/task"
require "minitest/test_task"

Hoe.plugin :halostatue

Hoe.plugins.delete :debug
Hoe.plugins.delete :newb
Hoe.plugins.delete :publish
Hoe.plugins.delete :signing
Hoe.plugins.delete :test

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
  extra_dev_deps << ["minitest", "~> 6.0"]
  extra_dev_deps << ["minitest-autotest", "~> 1.0"]
  extra_dev_deps << ["minitest-focus", "~> 1.1"]
  extra_dev_deps << ["rake", ">= 10.0", "< 14"]
  extra_dev_deps << ["rantly", "~> 3.0"]
  extra_dev_deps << ["rdoc", ">= 6.0", "< 8"]
  extra_dev_deps << ["simplecov", "~> 0.9"]
  extra_dev_deps << ["simplecov-lcov", "~> 0.9"]
  extra_dev_deps << ["standard", "~> 1.50"]
  extra_dev_deps << ["standard-thread_safety", "~> 1.0"]
  extra_dev_deps << ["fasterer", "~> 0.11"]
end

task :nocover do
  require "fileutils"
  FileUtils.rm_rf("./coverage")
end

# To be replaced with an integration test that uses rspec on a different suite
desc "Run all specifications"
RSpec::Core::RakeTask.new(:spec) do |t|
  rspec_dirs = %w[spec lib].join(":")
  t.rspec_opts = ["-I#{rspec_dirs}"]
end

task spec: :nocover

task default: :spec

Rake::Task["spec"].actions.uniq! { |a| a.source_location }

Minitest::TestTask.create :test
Minitest::TestTask.create :coverage do |t|
  formatters = <<-RUBY.split($/).join(" ")
    SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::LcovFormatter,
      SimpleCov::Formatter::SimpleFormatter
    ])
  RUBY
  t.test_prelude = <<-RUBY.split($/).join("; ")
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |config|
    config.report_with_single_file = true
    config.lcov_file_name = "lcov.info"
  end

  SimpleCov.start "test_frameworks" do
    enable_coverage :branch
    primary_coverage :branch
    formatter #{formatters}
  end
  RUBY
end

task test: :nocover
task default: :test

task :version do
  require "diff/lcs/version"
  puts Diff::LCS::VERSION
end

RDoc::Task.new do |config|
  config.title = "diff-lcs"
  config.main = "README.md"
  config.rdoc_dir = "doc"
  config.rdoc_files = hoe.spec.require_paths - ["Manifest.txt"] + hoe.spec.extra_rdoc_files
  config.markup = "markdown"
end
task docs: :rerdoc
