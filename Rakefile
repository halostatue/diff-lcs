require "rubygems"
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
  extra_dev_deps << ["hoe-halostatue", "~> 3.0"]
  extra_dev_deps << ["minitest", "~> 6.0"]
  extra_dev_deps << ["minitest-autotest", "~> 1.0"]
  extra_dev_deps << ["minitest-focus", "~> 1.1"]
  extra_dev_deps << ["rake", ">= 10.0", "< 14"]
  extra_dev_deps << ["rdoc", ">= 6.0", "< 8"]
  extra_dev_deps << ["simplecov", "~> 0.9"]
  extra_dev_deps << ["simplecov-lcov", "~> 0.9"]
  extra_dev_deps << ["standard", "~> 1.50"]
  extra_dev_deps << ["standard-thread_safety", "~> 1.0"]
  extra_dev_deps << ["fasterer", "~> 0.11"]
end

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

task default: :test

task :version do
  require "diff/lcs/version"
  puts Diff::LCS::VERSION
end

RDoc::Task.new do |config|
  config.title = "diff-lcs"
  config.main = "README.md"
  config.rdoc_dir = "doc"
  config.rdoc_files = hoe.spec.require_paths + hoe.spec.extra_rdoc_files -
    FileList["integration/golden/*.txt", "Manifest.txt"].to_a
  config.markup = "markdown"
end
task docs: :rerdoc

def rspec_to_golden(file)
  File.join("integration/golden", File.basename(file, "_spec.rb")) + ".txt"
end

def normalize_rspec_output(data)
  data
    .gsub(/Randomized with seed \d+/, "Randomized with seed XXXXX")
    .gsub(/Finished in [\d.]+ seconds/, "Finished in X.XXXXX seconds")
    .gsub(/files took [\d.]+ seconds to load/, "files took X.XXXXX seconds to load")
end

def unbundled(&block)
  if defined?(Bundler)
    Bundler.with_unbundled_env(&block)
  else
    block.call
  end
end

rspecs = FileList["integration/compare/*_spec.rb"]

namespace :integration do
  desc "Compare RSpec output with and without diff-lcs 2"
  task :compare do
    require "tempfile"
    base = Tempfile.create("baseline") { _1.path }
    work = Tempfile.create("working") { _1.path }

    unbundled { sh "gem install rspec" }

    rspecs.to_a.each do |rspec_file|
      basename = File.basename(rspec_file, "_spec.rb")

      base_contents = unbundled { `integration/runner rspec #{rspec_file} 2>&1` }
      base_contents = normalize_rspec_output(base_contents)

      work_contents = unbundled { `integration/runner rspec -Ilib -rdiff/lcs #{rspec_file} 2>&1` }
      work_contents = normalize_rspec_output(work_contents)

      if base_contents == work_contents
        puts "#{basename}: OK"
      else
        puts "#{basename}: FAIL"

        File.write(base, base_contents)
        File.write(work, work_contents)

        unbundled { sh "integration/runner -Ilib bin/ldiff -U #{base} #{work}" }
      end
    end
  end
end

desc "Run RSpec integration tests with diff-lcs 2.0"
task integration: ["integration:compare"] do
  sh "rspec -Ilib -r diff/lcs integration/*_spec.rb"
end
