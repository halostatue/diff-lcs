require "rubygems"
require "rspec"
require "rspec/core/rake_task"
require "hoe"
require "rake/clean"

Hoe.plugin :cov
Hoe.plugin :doofus
Hoe.plugin :gemspec2
Hoe.plugin :git2
Hoe.plugin :rubygems

if RUBY_VERSION < "1.9"
  class Array # :nodoc:
    def to_h
      Hash[*flatten(1)]
    end
  end

  class Gem::Specification # :nodoc:
    def metadata=(*)
    end

    def default_value(*)
    end
  end

  class Object # :nodoc:
    def caller_locations(*)
      []
    end
  end
end

_spec = Hoe.spec "diff-lcs" do
  developer("Austin Ziegler", "halostatue@gmail.com")

  self.history_file = "CHANGELOG.md"
  self.readme_file = "README.md"
  self.licenses = ["MIT", "Artistic-1.0-Perl", "GPL-2.0-or-later"]

  require_ruby_version ">= 1.8"

  spec_extras[:metadata] = ->(val) {
    val["rubygems_mfa_required"] = "true"
    val["changelog_uri"] = "https://github.com/halostatue/diff-lcs/blob/main/CHANGELOG.md"
  }

  extra_dev_deps << ["hoe", ">= 3.0", "< 5"]
  extra_dev_deps << ["hoe-doofus", "~> 1.0"]
  extra_dev_deps << ["hoe-gemspec2", "~> 1.1"]
  extra_dev_deps << ["hoe-git2", "~> 1.7"]
  extra_dev_deps << ["hoe-rubygems", "~> 1.0"]
  extra_dev_deps << ["rspec", ">= 2.0", "< 4"]
  extra_dev_deps << ["rake", ">= 10.0", "< 14"]
  extra_dev_deps << ["rdoc", ">= 6.3.1", "< 7"]
end

desc "Run all specifications"
RSpec::Core::RakeTask.new(:spec) do |t|
  rspec_dirs = %w[spec lib].join(":")
  t.rspec_opts = ["-I#{rspec_dirs}"]
end

Rake::Task["spec"].actions.uniq! { |a| a.source_location }

# standard:disable Style/HashSyntax
task :default => :spec unless Rake::Task["default"].prereqs.include?("spec")
task :test => :spec unless Rake::Task["test"].prereqs.include?("spec")
# standard:enable Style/HashSyntax

if RUBY_VERSION >= "2.0" && RUBY_ENGINE == "ruby"
  namespace :spec do
    desc "Runs test coverage. Only works Ruby 2.0+ and assumes 'simplecov' is installed."
    task :coverage do
      ENV["COVERAGE"] = "yes"
      Rake::Task["spec"].execute
    end
  end
end

task :ruby18 do
  # standard:disable Layout/HeredocIndentation
  puts <<-MESSAGE
You are starting a barebones Ruby 1.8 docker environment. You will need to
do the following:

- mv Gemfile.lock{,.v2}
- gem install bundler --version 1.17.2 --no-ri --no-rdoc
- ruby -S bundle
- rake

Don't forget to restore your Gemfile.lock after testing.

  MESSAGE
  # standard:enable Layout/HeredocIndentation
  sh "docker run -it --rm -v #{Dir.pwd}:/root/diff-lcs bellbind/docker-ruby18-rails2 bash -l"
end
