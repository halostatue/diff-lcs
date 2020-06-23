# frozen_string_literal: true

require 'rubygems'
require 'rspec'
require 'hoe'

Hoe.plugin :bundler
Hoe.plugin :doofus
Hoe.plugin :email unless ENV['CI'] or ENV['TRAVIS']
Hoe.plugin :gemspec2
Hoe.plugin :git
Hoe.plugin :travis

_spec = Hoe.spec 'diff-lcs' do
  developer('Austin Ziegler', 'halostatue@gmail.com')

  require_ruby_version '>= 1.8'

  self.history_file = 'History.md'
  self.readme_file = 'README.rdoc'
  self.licenses = ['MIT', 'Artistic-2.0', 'GPL-2.0+']

  extra_dev_deps << ['hoe-doofus', '~> 1.0']
  extra_dev_deps << ['hoe-gemspec2', '~> 1.1']
  extra_dev_deps << ['hoe-git', '~> 1.6']
  extra_dev_deps << ['hoe-rubygems', '~> 1.0']
  extra_dev_deps << ['rspec', '>= 2.0', '< 4']
  extra_dev_deps << ['rake', '>= 10.0', '< 14']
  extra_dev_deps << ['rdoc', '>= 0']
end

if RUBY_VERSION >= '2.0' && RUBY_ENGINE == 'ruby'
  namespace :spec do
    desc "Runs test coverage. Only works Ruby 2.0+ and assumes 'simplecov' is installed."
    task :coverage do
      ENV['COVERAGE'] = 'yes'
      Rake::Task['spec'].execute
    end
  end
end
