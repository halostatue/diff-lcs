# -*- ruby encoding: utf-8 -*-

require 'rubygems'
require 'rspec'
require 'hoe'

Hoe.plugin :bundler
Hoe.plugin :deveiate
Hoe.plugin :doofus
Hoe.plugin :gemspec
Hoe.plugin :git
Hoe.plugin :travis

Hoe.spec 'diff-lcs' do
  developer('Austin Ziegler', 'austin@rubyforge.org')

  self.history_file = 'History.rdoc'
  self.readme_file = 'README.rdoc'
  self.extra_rdoc_files = FileList["*.rdoc"].to_a

  self.extra_dev_deps << ['rspec', '~> 2.0']
  self.extra_dev_deps << ['rake', '~> 10.0']
end

unless Rake::Task.task_defined? :test
  task :test => :spec
end

# vim: syntax=ruby
