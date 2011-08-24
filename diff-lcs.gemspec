# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{diff-lcs}
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Austin Ziegler}]
  s.date = %q{2011-08-24}
  s.description = %q{Diff::LCS is a port of Perl's Algorithm::Diff that uses the McIlroy-Hunt
longest common subsequence (LCS) algorithm to compute intelligent differences
between two sequenced enumerable containers. The implementation is based on
Mario I. Wolczko's {Smalltalk version 1.2}[ftp://st.cs.uiuc.edu/pub/Smalltalk/MANCHESTER/manchester/4.0/diff.st]
(1993) and Ned Konz's Perl version
{Algorithm::Diff 1.15}[http://search.cpan.org/~nedkonz/Algorithm-Diff-1.15/].

This is release 1.1.3, fixing several small bugs found over the years. Version
1.1.0 added new features, including the ability to #patch and #unpatch changes
as well as a new contextual diff callback, Diff::LCS::ContextDiffCallbacks,
that should improve the context sensitivity of patching.

This library is called Diff::LCS because of an early version of Algorithm::Diff
which was restrictively licensed. This version has seen a minor license change:
instead of being under Ruby's license as an option, the third optional license
is the MIT license.}
  s.email = [%q{austin@rubyforge.org}]
  s.executables = [%q{htmldiff}, %q{ldiff}]
  s.extra_rdoc_files = [%q{Manifest.txt}, %q{docs/COPYING.txt}, %q{History.rdoc}, %q{License.rdoc}, %q{README.rdoc}]
  s.files = [%q{History.rdoc}, %q{License.rdoc}, %q{Manifest.txt}, %q{README.rdoc}, %q{Rakefile}, %q{bin/htmldiff}, %q{bin/ldiff}, %q{diff-lcs.gemspec}, %q{docs/COPYING.txt}, %q{docs/artistic.html}, %q{lib/diff-lcs.rb}, %q{lib/diff/lcs.rb}, %q{lib/diff/lcs/array.rb}, %q{lib/diff/lcs/block.rb}, %q{lib/diff/lcs/callbacks.rb}, %q{lib/diff/lcs/change.rb}, %q{lib/diff/lcs/htmldiff.rb}, %q{lib/diff/lcs/hunk.rb}, %q{lib/diff/lcs/ldiff.rb}, %q{lib/diff/lcs/string.rb}, %q{spec/diff_spec.rb}, %q{spec/lcs_spec.rb}, %q{spec/patch_spec.rb}, %q{spec/sdiff_spec.rb}, %q{spec/spec_helper.rb}, %q{spec/traverse_balanced_spec.rb}, %q{spec/traverse_sequences_spec.rb}]
  s.rdoc_options = [%q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{ruwiki}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Diff::LCS is a port of Perl's Algorithm::Diff that uses the McIlroy-Hunt longest common subsequence (LCS) algorithm to compute intelligent differences between two sequenced enumerable containers}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<hoe>, ["~> 2.12"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<hoe>, ["~> 2.12"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<hoe>, ["~> 2.12"])
  end
end
