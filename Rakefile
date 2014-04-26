# -*- ruby encoding: utf-8 -*-

require 'rubygems'
require 'rspec'
require 'hoe'

Hoe.plugin :bundler
Hoe.plugin :doofus
Hoe.plugin :email unless ENV['CI'] or ENV['TRAVIS']
Hoe.plugin :gemspec2
Hoe.plugin :git
Hoe.plugin :travis

spec = Hoe.spec 'diff-lcs' do
  developer('Austin Ziegler', 'halostatue@gmail.com')

  self.need_tar = true

  self.history_file = 'History.rdoc'
  self.readme_file = 'README.rdoc'
  self.extra_rdoc_files = FileList["*.rdoc"].to_a

  %w(MIT Perl\ Artistic\ v2 GNU\ GPL\ v2).each { |l| self.license l }

  self.extra_dev_deps << ['hoe-bundler', '~> 1.2']
  self.extra_dev_deps << ['hoe-doofus', '~> 1.0']
  self.extra_dev_deps << ['hoe-gemspec2', '~> 1.1']
  self.extra_dev_deps << ['hoe-git', '~> 1.5']
  self.extra_dev_deps << ['hoe-rubygems', '~> 1.0']
  self.extra_dev_deps << ['hoe-travis', '~> 1.2']
  self.extra_dev_deps << ['rake', '~> 10.0']
  self.extra_dev_deps << ['rspec', '~> 2.0']

  if RUBY_VERSION >= '1.9' and (ENV['CI'] or ENV['TRAVIS'])
    self.extra_dev_deps << ['simplecov', '~> 0.8']
    self.extra_dev_deps << ['coveralls', '~> 0.7']
  end
end

unless Rake::Task.task_defined? :test
  task :test => :spec
  Rake::Task['travis'].prerequisites.replace(%w(spec))
end

if RUBY_VERSION >= '1.9'
  namespace :spec do
    desc "Submit test coverage to Coveralls"
    task :coveralls do
      ENV['COVERAGE'] = ENV['COVERALLS'] = 'yes'
    end

    desc "Runs test coverage. Only works Ruby 1.9+ and assumes 'simplecov' is installed."
    task :coverage do
      ENV['COVERAGE'] = 'yes'
      Rake::Task['spec'].execute
    end
  end

  Rake::Task['travis'].prerequisites.replace(%w(spec:coveralls))
end

# vim: syntax=ruby
