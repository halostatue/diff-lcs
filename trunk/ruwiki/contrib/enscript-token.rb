# By Javier Fontan <jfontan@pc3d.cesga.es>

require "open3"

class Ruwiki::Wiki::CodeColor < Ruwiki::Wiki::Token
  def self.rank
    0
  end

  def self.regexp
    %r<\{\{\{(?::(\w+)\b)?(.*?)\}\}\}>m
  end

  def replace
    cap = @match.captures

    if cap[0].nil?
      language = "ruby"
    else
      language = cap[0]
    end

    text = cap[1]

    i, o, e = Open3.popen3("enscript -B --color=emacs -Whtml -E#{language} -o -")
    i.print text
    i.close

    re_script = %r{(<PRE>.*?</pre>)}mio
    c = o.readlines[1..-1].join("\n")
    re_script.match(c).captures[0]
  end

  def self.post_replace(content)
    content.gsub!(%r{<pre>\n}im, '<pre>')
    content.gsub!(%r{\n</pre>}im, '</pre>')
    content.gsub!(%r{<font color="(.+?)">}im, '<span style="color: \1">')
    content.gsub!(%r{</font>}im, '</span>')
    content.gsub!(%r{<B>}i, '<b>')
    content.gsub!(%r{</B}i, '</b>')
    content
  end
end
