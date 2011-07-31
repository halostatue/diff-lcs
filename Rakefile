# -*- ruby encoding: utf-8 -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :doofus
Hoe.plugin :gemspec
Hoe.plugin :git

Hoe.spec 'diff-lcs' do |spec|
  spec.rubyforge_name = 'ruwiki'

  developer('Austin Ziegler', 'austin@rubyforge.org')

  spec.remote_rdoc_dir = 'diff-lcs/rdoc'
  spec.rsync_args << ' --exclude=statsvn/'

  spec.history_file = 'History.rdoc'
  spec.readme_file = 'README.rdoc'
  spec.extra_rdoc_files = FileList["*.rdoc"].to_a

  spec.extra_dev_deps << ['rspec', '~> 2.0']
end

# vim: syntax=ruby
