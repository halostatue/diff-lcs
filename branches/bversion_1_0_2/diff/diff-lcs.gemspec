Gem::Specification.new do |s|
  s.name = %{diff-lcs}
  s.version = %{1.0.4}
  s.author = %{Austin Ziegler}
  s.email = %{diff-lcs@halostatue.ca}
  s.homepage = %{http://rubyforge.org/projects/ruwiki/}
  s.rubyforge_project = %{ruwiki}

  s.files = Dir.glob("**/*").delete_if do |item|
    item.include?("CVS") or item.include?(".svn") or
    item == "install.rb" or item =~ /~$/ or
    item =~ /gem(?:spec)?$/
  end

  s.summary = %{Provides a list of changes that represent the difference between two sequenced collections.}
  s.platform = Gem::Platform::RUBY

  s.required_ruby_version = %(>=1.8.1)

  s.executables = %w(ldiff htmldiff)
  s.bindir = %(bin)
  s.default_executable = %(ldiff)

  s.test_suite_file = %w{tests/00test.rb}

  s.autorequire = %{diff/lcs}
  s.require_paths = %w{lib}

  description = []
  File.open("README") do |file|
    file.each do |line|
      line.chomp!
      break if line.empty?
      description << "#{line.gsub(/\[\d\]/, '')}"
    end
  end
  s.description = description[2..-1].join(" ")

  s.has_rdoc = true
  s.rdoc_options = ["--title", "Diff::LCS -- A Diff Algorithm", "--main", "README", "--line-numbers"]
  s.extra_rdoc_files = %w(README ChangeLog Install)
end
