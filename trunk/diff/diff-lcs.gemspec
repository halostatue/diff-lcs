Gem::Specification.new do |s|
  s.name = %q{diff-lcs}
  s.version = %q{1.0.0}
  s.summary = %q{Manages a MIME Content-Type that will return the Content-Type for a given filename.}
  s.platform = Gem::Platform::RUBY

  s.has_rdoc = true

  s.test_suite_file = %w{tests/00test.rb}

  s.autorequire = %q{diff/lcs}
  s.require_paths = %w{lib}

  s.files = Dir.glob("**/*").delete_if do |item|
    item.include?("CVS") or item.include?(".svn") or
    item == "install.rb" or item =~ /~$/ or
    item =~ /gem(?:spec)?$/
  end

  s.author = %q{Austin Ziegler}
  s.email = %q{diff-lcs@halostatue.ca}
  s.homepage = %q{http://rubyforge.org/projects/ruwiki/}
  description = []
  File.open("README") do |file|
    file.each do |line|
      line.chomp!
      break if line.empty?
      description << "#{line.gsub(/\[\d\]/, '')}"
    end
  end
  s.description = description[2..-1].join(" ")
end
