# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "diff-lcs"
  s.version = "1.2.0.20130120032021"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Austin Ziegler"]
  s.date = "2013-01-20"
  s.description = "Diff::LCS is a port of Perl's Algorithm::Diff that uses the McIlroy-Hunt\nlongest common subsequence (LCS) algorithm to compute intelligent differences\nbetween two sequenced enumerable containers. The implementation is based on\nMario I. Wolczko's {Smalltalk version 1.2}[ftp://st.cs.uiuc.edu/pub/Smalltalk/MANCHESTER/manchester/4.0/diff.st]\n(1993) and Ned Konz's Perl version\n{Algorithm::Diff 1.15}[http://search.cpan.org/~nedkonz/Algorithm-Diff-1.15/].\n\nThis is release 1.1.3, fixing several small bugs found over the years. Version\n1.1.0 added new features, including the ability to #patch and #unpatch changes\nas well as a new contextual diff callback, Diff::LCS::ContextDiffCallbacks,\nthat should improve the context sensitivity of patching.\n\nThis library is called Diff::LCS because of an early version of Algorithm::Diff\nwhich was restrictively licensed. This version has seen a minor license change:\ninstead of being under Ruby's license as an option, the third optional license\nis the MIT license."
  s.email = ["austin@rubyforge.org"]
  s.executables = ["htmldiff", "ldiff"]
  s.extra_rdoc_files = ["History.rdoc", "License.rdoc", "Manifest.txt", "README.rdoc", "docs/COPYING.txt", "History.rdoc", "License.rdoc", "README.rdoc"]
  s.files = [".autotest", ".rspec", "History.rdoc", "License.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "autotest/discover.rb", "bin/htmldiff", "bin/ldiff", "diff-lcs.gemspec", "docs/COPYING.txt", "docs/artistic.html", "lib/diff-lcs.rb", "lib/diff/lcs.rb", "lib/diff/lcs/array.rb", "lib/diff/lcs/block.rb", "lib/diff/lcs/callbacks.rb", "lib/diff/lcs/change.rb", "lib/diff/lcs/htmldiff.rb", "lib/diff/lcs/hunk.rb", "lib/diff/lcs/internals.rb", "lib/diff/lcs/ldiff.rb", "lib/diff/lcs/string.rb", "spec/change_spec.rb", "spec/diff_spec.rb", "spec/issues_spec.rb", "spec/lcs_spec.rb", "spec/patch_spec.rb", "spec/sdiff_spec.rb", "spec/spec_helper.rb", "spec/traverse_balanced_spec.rb", "spec/traverse_sequences_spec.rb", ".gemtest"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "ruwiki"
  s.rubygems_version = "1.8.24"
  s.summary = "Diff::LCS is a port of Perl's Algorithm::Diff that uses the McIlroy-Hunt longest common subsequence (LCS) algorithm to compute intelligent differences between two sequenced enumerable containers"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.4"])
    else
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<hoe>, ["~> 3.4"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<hoe>, ["~> 3.4"])
  end
end
