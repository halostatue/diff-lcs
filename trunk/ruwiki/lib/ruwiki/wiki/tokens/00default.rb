#--
# Ruwiki
#   Copyright © 2002 - 2003, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

# $debug = File.open("output.txt", "w")

class Ruwiki
  class Wiki
      # The Paragraph Token class changes blank lines to <p> tags. This class,
      # under the current implementation, should be *first* in the Token list
      # after Token.
    class Paragraph < Ruwiki::Wiki::Token
        # This Token is #rank 0, because it should be first in the Token list.
      def self.rank
        0
      end

        # Matches blank lines. %r{^\s*$}
      def self.regexp
        %r{(^\s*$)}
      end

        # Replaces with "<p>"
      def replace
        "</p><p>"
      end

        # Ensures that <p> won't be surrounded by <br> tags.
      def self.post_replace(content)
        content.gsub!(%r{\A}, '<p>')
        content.gsub!(%r{\z}, '</p>')
        content.gsub!(%r{^}, '<p>')
        content.gsub!(%r{\n}, "</p>\n")
        content.gsub!(%r{<p>(<p>)+}, '<p>')
        content.gsub!(%r{</p>(</p>)+}, '</p>')
        content.gsub!(%r{((?:<p>(?:.*?)</p>\n)+?<p></p><p></p>)}) do |m|
          r = m.gsub(%r{</p>\n<p>}, "\n<p>")
          r.gsub!(%r{<p></p><p></p>}, "</p>")
          r.gsub!(%r{\n<p>}, "\n")
          r.gsub!(%r{\n</p>}, '</p>')
          r
        end
        content.gsub!(%r{<p></p>}, '')
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

        # Matches indented text. %r{^(\s+\S.*)$}
      def self.regexp
        %r{^(\s+\S.*)$}
      end

        # Replaces the text to <pre>content</pre>.
      def replace
        content = @match.captures[0]
        content.gsub!(/&/, '&amp;')
        content.gsub!(/</, '&lt;')
        content.gsub!(/>/, '&gt;')

        %Q{</p><pre>#{content}</pre>}
      end

        # Converts cases of %r{</pre>(\n|<br ?/?>)<pre>} to \1.
      def self.post_replace(content)
        content.gsub!(%r{</pre>((\n)*</p>(\n)*)?<pre>}, "\n")
        content.gsub!(%r{</pre>(\n|<br ?/?>)?<pre>}, '\1')
        content.gsub!(%r{<p><pre>}, '<pre>')
        content.gsub!(%r{</pre></p>}, '</pre>')
        content
      end
    end

    RE_URI_SCHEME = %r{[\w.]+?:}
    RE_URI_PATH   = %r{[^\s<>\]]}
    RE_URI_TEXT   = %r{[^\]]*}
    RE_IMAGE      = /(jpg|jpeg|png|gif)$/

      # Converts URLs in the form of [url] to numbered links.
    class NumberedLinks < Ruwiki::Wiki::Token
      class << self
        attr_accessor :count
      end

      def self.rank
        2
      end

      def self.regexp
        %r{\[(#{RE_URI_SCHEME}(?:#{RE_URI_PATH})*?)\]}
      end

      def replace
        extlink = @match.captures[0]

        NumberedLinks.count ||= 0
        NumberedLinks.count += 1
        name = "[#{NumberedLinks.count}]"

        if extlink =~ RE_IMAGE
          %Q{<img src="#{extlink}" title="#{name}" alt="#{name}" />}
        else
          %Q{<a class="rw_extlink" href="#{extlink}">#{name}</a>}
        end
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

        if extlink =~ RE_IMAGE
          %Q{<img src="#{extlink}" title="#{name}" alt="#{name}" />}
        else
          %Q{<a class="rw_extlink" href="#{extlink}">#{name}</a>}
        end
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

      def replace
        extlink = @match.captures[0]

        if extlink =~ RE_IMAGE
          %Q{<img src="#{extlink}" title="Image at: #{extlink}" alt="Image at: #{extlink}" />}
        else
          %Q{<a class="rw_extlink" href="#{extlink}">#{extlink}</a>}
        end
      end
    end

      # Creates a horizontal rule.
    class HRule < Ruwiki::Wiki::Token
      def self.regexp
        %r|^\\?-{4,}|
      end

      def replace
        "<hr />"
      end

      def restore
        @match[0][1 .. -1]
      end

      def self.post_replace(content)
        content.gsub!(%r{(<p>)*<hr ?/?>(</p>)*}, "<hr />")
        content.gsub!(%r{\n<hr />}, "</p>\n<hr />")
        content.gsub!(%r{<hr ?/?>\n<br ?/?>}, "<hr />")
        content.gsub!(%r{(\n|<br ?/?>)?<hr>(\n|<br ?/?>)?}, "<hr />")
        content
      end
    end
  end
end
