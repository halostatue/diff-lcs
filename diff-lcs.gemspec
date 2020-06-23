# -*- encoding: utf-8 -*-
# stub: diff-lcs 1.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "diff-lcs".freeze
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/halostatue/diff-lcs/issues", "homepage_uri" => "https://github.com/halostatue/diff-lcs", "source_code_uri" => "https://github.com/halostatue/diff-lcs" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "2020-06-23"
  s.description = "Diff::LCS computes the difference between two Enumerable sequences using the\nMcIlroy-Hunt longest common subsequence (LCS) algorithm. It includes utilities\nto create a simple HTML diff output format and a standard diff-like tool.\n\nThis is release 1.4, providing a simple extension that allows for\nDiff::LCS::Change objects to be treated implicitly as arrays. Ruby versions\nbelow 2.5 are soft-deprecated.\n\nThis means that older versions are no longer part of the CI test suite. If any\nchanges have been introduced that break those versions, bug reports and patches\nwill be accepted, but it will be up to the reporter to verify any fixes prior\nto release. A future release will completely break compatibility.".freeze
  s.email = ["halostatue@gmail.com".freeze]
  s.executables = ["htmldiff".freeze, "ldiff".freeze]
  s.extra_rdoc_files = ["Code-of-Conduct.md".freeze, "Contributing.md".freeze, "History.md".freeze, "License.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "docs/COPYING.txt".freeze, "docs/artistic.txt".freeze]
  s.files = [".rspec".freeze, "Code-of-Conduct.md".freeze, "Contributing.md".freeze, "History.md".freeze, "License.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "autotest/discover.rb".freeze, "bin/htmldiff".freeze, "bin/ldiff".freeze, "docs/COPYING.txt".freeze, "docs/artistic.txt".freeze, "lib/diff-lcs.rb".freeze, "lib/diff/lcs.rb".freeze, "lib/diff/lcs/array.rb".freeze, "lib/diff/lcs/backports.rb".freeze, "lib/diff/lcs/block.rb".freeze, "lib/diff/lcs/callbacks.rb".freeze, "lib/diff/lcs/change.rb".freeze, "lib/diff/lcs/htmldiff.rb".freeze, "lib/diff/lcs/hunk.rb".freeze, "lib/diff/lcs/internals.rb".freeze, "lib/diff/lcs/ldiff.rb".freeze, "lib/diff/lcs/string.rb".freeze, "spec/change_spec.rb".freeze, "spec/diff_spec.rb".freeze, "spec/fixtures/aX".freeze, "spec/fixtures/bXaX".freeze, "spec/fixtures/ds1.csv".freeze, "spec/fixtures/ds2.csv".freeze, "spec/fixtures/ldiff/output.diff".freeze, "spec/fixtures/ldiff/output.diff-c".freeze, "spec/fixtures/ldiff/output.diff-e".freeze, "spec/fixtures/ldiff/output.diff-f".freeze, "spec/fixtures/ldiff/output.diff-u".freeze, "spec/hunk_spec.rb".freeze, "spec/issues_spec.rb".freeze, "spec/lcs_spec.rb".freeze, "spec/ldiff_spec.rb".freeze, "spec/patch_spec.rb".freeze, "spec/sdiff_spec.rb".freeze, "spec/spec_helper.rb".freeze, "spec/traverse_balanced_spec.rb".freeze, "spec/traverse_sequences_spec.rb".freeze]
  s.homepage = "https://github.com/halostatue/diff-lcs".freeze
  s.licenses = ["MIT".freeze, "Artistic-2.0".freeze, "GPL-2.0+".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8".freeze)
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Diff::LCS computes the difference between two Enumerable sequences using the McIlroy-Hunt longest common subsequence (LCS) algorithm".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
      s.add_development_dependency(%q<hoe-git>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 2.0", "< 4"])
      s.add_development_dependency(%q<rake>.freeze, [">= 10.0", "< 14"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.22"])
    else
      s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
      s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
      s.add_dependency(%q<hoe-git>.freeze, ["~> 1.6"])
      s.add_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rspec>.freeze, [">= 2.0", "< 4"])
      s.add_dependency(%q<rake>.freeze, [">= 10.0", "< 14"])
      s.add_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.22"])
    end
  else
    s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>.freeze, ["~> 1.6"])
    s.add_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rspec>.freeze, [">= 2.0", "< 4"])
    s.add_dependency(%q<rake>.freeze, [">= 10.0", "< 14"])
    s.add_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.22"])
  end
end
