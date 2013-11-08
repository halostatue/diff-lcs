# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "diff-lcs"
  s.version = "1.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Austin Ziegler"]
  s.date = "2013-11-08"
  s.description = "Diff::LCS computes the difference between two Enumerable sequences using the\nMcIlroy-Hunt longest common subsequence (LCS) algorithm. It includes utilities\nto create a simple HTML diff output format and a standard diff-like tool.\n\nThis is release 1.2.4, fixing a bug introduced after diff-lcs 1.1.3 that did\nnot properly prune common sequences at the beginning of a comparison set.\nThanks to Paul Kunysch for fixing this issue.\n\nCoincident with the release of diff-lcs 1.2.3, we reported an issue with\nRubinius in 1.9 mode\n({rubinius/rubinius#2268}[https://github.com/rubinius/rubinius/issues/2268]).\nWe are happy to report that this issue has been resolved."
  s.email = ["austin@rubyforge.org"]
  s.executables = ["htmldiff", "ldiff"]
  s.extra_rdoc_files = ["Contributing.rdoc", "History.rdoc", "License.rdoc", "Manifest.txt", "README.rdoc", "docs/COPYING.txt", "docs/artistic.txt", "Contributing.rdoc", "History.rdoc", "License.rdoc", "README.rdoc"]
  s.files = [".autotest", ".gemtest", ".hoerc", ".rspec", ".travis.yml", "Contributing.rdoc", "Gemfile", "History.rdoc", "License.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "autotest/discover.rb", "bin/htmldiff", "bin/ldiff", "docs/COPYING.txt", "docs/artistic.txt", "lib/diff-lcs.rb", "lib/diff/lcs.rb", "lib/diff/lcs/array.rb", "lib/diff/lcs/block.rb", "lib/diff/lcs/callbacks.rb", "lib/diff/lcs/change.rb", "lib/diff/lcs/htmldiff.rb", "lib/diff/lcs/hunk.rb", "lib/diff/lcs/internals.rb", "lib/diff/lcs/ldiff.rb", "lib/diff/lcs/string.rb", "spec/change_spec.rb", "spec/diff_spec.rb", "spec/hunk_spec.rb", "spec/issues_spec.rb", "spec/lcs_spec.rb", "spec/patch_spec.rb", "spec/sdiff_spec.rb", "spec/spec_helper.rb", "spec/traverse_balanced_spec.rb", "spec/traverse_sequences_spec.rb"]
  s.homepage = "http://diff-lcs.rubyforge.org/"
  s.licenses = ["MIT", "Perl Artistic v2", "GNU GPL v2"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "diff-lcs"
  s.rubygems_version = "2.0.7"
  s.summary = "Diff::LCS computes the difference between two Enumerable sequences using the McIlroy-Hunt longest common subsequence (LCS) algorithm"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe-bundler>, ["~> 1.2"])
      s.add_development_dependency(%q<hoe-doofus>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
      s.add_development_dependency(%q<hoe-git>, ["~> 1.5"])
      s.add_development_dependency(%q<hoe-rubygems>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-travis>, ["~> 1.2"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.7"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe-bundler>, ["~> 1.2"])
      s.add_dependency(%q<hoe-doofus>, ["~> 1.0"])
      s.add_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
      s.add_dependency(%q<hoe-git>, ["~> 1.5"])
      s.add_dependency(%q<hoe-rubygems>, ["~> 1.0"])
      s.add_dependency(%q<hoe-travis>, ["~> 1.2"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<hoe>, ["~> 3.7"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe-bundler>, ["~> 1.2"])
    s.add_dependency(%q<hoe-doofus>, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>, ["~> 1.5"])
    s.add_dependency(%q<hoe-rubygems>, ["~> 1.0"])
    s.add_dependency(%q<hoe-travis>, ["~> 1.2"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<hoe>, ["~> 3.7"])
  end
end
