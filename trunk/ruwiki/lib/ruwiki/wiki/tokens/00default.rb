#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

# $debug = File.open("output.txt", "wb")

class Ruwiki::Wiki
    # The Paragraph Token class changes blank lines to <p> tags. This class,
    # under the current implementation, should be *first* in the Token list
    # after Token.
  class Paragraph < Ruwiki::Wiki::Token
      # This Token is #rank 0, because it should be first in the Token list.
    def self.rank
      0
    end

      # Matches blank lines. %r{^$}
    def self.regexp
      %r{(^$)}
    end

    def replace
      %Q(</p><p class="rwtk_Paragraph">)
    end

      # Ensures that <p> won't be surrounded by <br> tags.
    def self.post_replace(content)
      content.gsub!(%r{\A}, '<p class="rwtk_Paragraph">')
      content.gsub!(%r{\z}, '</p>')
      content.gsub!(%r{\n(</p>)}, '\1')
      content.gsub!(%r{(<p[^>]*>)\n}, '\1')
      content.gsub!(%r{(</p>)(<p[^>]*>)}) { "#{$1}\n#{$2}" }
      content.gsub!(%r{(<pre[^>]*>.*?)<p[^>]*></p>(.*?</pre>)}) { "#{$1}\n#{$2}" }
      content.gsub!(%r{<p[^>]*></p>}, '')
      content.gsub!(%r{^\n(<p[^>]*>)}, '\1')
      content
    end
  end

    # The Code Token class converts indented text to "unformatted" (<pre>)
    # text. This class should be *second* in the Token list.
  class Code < Ruwiki::Wiki::Token
      # This Token is #rank 1, because it should be second in the Token list.
    def self.rank
      1
    end

      # Matches indented text. %r{^(\s+\S?.*)$}
    def self.regexp
      %r{^([ \t]+[^\n]*)\n}
    end

      # Replaces the text to <pre>content</pre>.
    def replace
      content = Ruwiki.clean_entities(@match.captures[0])

      %Q{</p><pre class="rwtk_Code">#{content}</pre>\n}
    end

      # Converts cases of %r{</pre>(\n|<br ?/?>)<pre>} to \1.
    def self.post_replace(content)
      content.gsub!(%r{</pre>((\n)*</p>(\n)*)?<pre[^>]*>}, "\n")
      content.gsub!(%r{</pre>(\n|<br ?/?>)?<pre[^>]*>}, '\1')
      content.gsub!(%r{<p[^>]*>(<pre[^>]*>)}, '\1')
      content.gsub!(%r{</pre></p>}, '</pre>')
#     content.gsub!(%r{(<pre[^>]*>.*?)<p[^>]*></p>(.*?</pre>)}) { "#{$1}\n#{$2}" }
      content
    end
  end

  RE_URI_SCHEME = %r{[-a-z0-9+.]{3,}?:}
  RE_URI_PATH   = %r{[^\s<>\]]}
  RE_URI_TEXT   = %r{[^\]]*}

  def self.redirect(uri)
    "http://www.google.com/url?sa=D&q=#{CGI.escape(uri)}"
  end

    # Converts URLs in the form of [url] to numbered links.
  class NumberedLinks < Ruwiki::Wiki::Token
    class << self
      def increment
        @count ||= 0
        @count += 1
      end

      def reset
        @count = 0
      end
    end

    def self.rank
      2
    end

    def self.regexp
      %r{\[(#{RE_URI_SCHEME}(?:#{RE_URI_PATH})*?)\]}
    end

    def replace
      extlink = @match.captures[0]

      name = "[#{NumberedLinks.increment}]"

      %Q{<a class="rwtk_NumberedLinks" href="#{Ruwiki::Wiki.redirect(extlink)}">#{name}</a>}
    end
  end

  class Image < Ruwiki::Wiki::Token
    def self.rank
      1
    end

    RE_IMAGE_OPTIONS=%r{([^=]+)=("[^"]+"|[^ ]+)}

    def self.regexp
      %r{\[image\s*:\s*(#{RE_URI_SCHEME}(?:#{RE_URI_PATH})*?)(\s+[^\]]+)?\]}
    end

    def replace
      options = { 'src' => %Q("#{@match.captures[0]}") }
      groups  = @match.captures[1]
      unless groups.nil?
        groups.scan(RE_IMAGE_OPTIONS).each { |gg| options[gg[0].strip] = gg[1].strip }
      end

      unless options['numbered'].nil? or options['numbered'] == "false"
        options['title'] = %Q("[#{NumberedLinks.increment}]")
        options.delete('numbered')
      end

      options['title'] ||= options['alt']
      options['title'] ||= options['src']
      options['alt']   ||= options['title']

      ss = ""
      options.keys.sort.map { |kk| ss << %Q( #{kk}=#{options[kk]}) }

      %Q{<img class="rwtk_Image"#{ss} />}
    end
  end

    # Converts URLs in the form of [url name] to named links.
  class NamedLinks < Ruwiki::Wiki::Token
    def self.rank
      3
    end

    def self.regexp
      %r{\[(#{RE_URI_SCHEME}(?:#{RE_URI_PATH})*?)\s+(#{RE_URI_TEXT})\]}
    end

    def replace
      extlink = @match.captures[0]
      name    = @match.captures[1]

      %Q{<a class="rwtk_NamedLinks" href="#{Ruwiki::Wiki.redirect(extlink)}">#{name}</a>}
    end
  end

    # Converts URLs to links where the "name" of the link is the URL itself.
  class ExternalLinks < Ruwiki::Wiki::Token
    def self.rank
      501
    end

    def self.regexp
      %r{\b(#{RE_URI_SCHEME}#{RE_URI_PATH}+)}
    end

    def restore
      @match[0]
    end

    def replace
      extlink = @match.captures[0]

      %Q{<a class="rwtk_ExternalLinks" href="#{Ruwiki::Wiki.redirect(extlink)}">#{extlink}</a>}
    end
  end

    # Creates a horizontal rule.
  class HRule < Ruwiki::Wiki::Token
    def self.regexp
      %r|^\\?-{4,}|
    end

    def replace
      %Q(<hr class="rwtk_HRule" />)
    end

    def restore
      @match[0][1 .. -1]
    end

    def self.post_replace(content)
      content.gsub!(%r{(<p[^>]*>)*(<hr[^ />]* ?/?>)(</p>)*}, '\1')
      content.gsub!(%r{\n<hr />}, "</p>\n<hr />")
      content.gsub!(%r{<hr ?/?>\n<br ?/?>}, "<hr />")
      content.gsub!(%r{(\n|<br ?/?>)?<hr>(\n|<br ?/?>)?}, "<hr />")
      content
    end
  end
end
