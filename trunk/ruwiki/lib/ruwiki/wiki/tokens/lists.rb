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
class Ruwiki
  class Wiki
      # Produces Lists
    class Lists < Ruwiki::Wiki::Token
      def self.regexp
        %r{^\\?((\*)+|(#)+)\s+(.*)}
      end

      def replace
        content = @match[4]

        if @match[3].nil?
          char = '*'
          elem = 'ul'
        else
          char = '#'
          elem = 'ol'
        end

        indent = @match[1].count(char)

        pre   = ""
        post  = ""
        indent.times do
          pre   << "<#{elem}><li>"
          post  << "</li></#{elem}>"
        end
        "#{pre}#{content}#{post}"
      end

      def restore
        @match[0][1 .. -1]
      end

      def self.post_replace(content)
        content.gsub!(%r{<p><([uo]l)>}, '<\1>')
        content.gsub!(%r{</([uo]l)></p>}, '</\1>')
        content.gsub!(%r{</[uo]l>\n?<[uo]l>}, '')
        content.gsub!(%r{</ol>(\n|(<br ?/?>))?<ol>}, '')
        content.gsub!(%r{</ul>(\n|(<br ?/?>))?<ul>}, '')
        content.gsub!(%r{<li><([uo]l)>}, '<\1>')
        content.gsub!(%r{</li><li>}, "</li>\n<li>")
        content.gsub!(%r{</([uo]l)></li>}, '</\1>')
        content.gsub!(%r{([^>])\n<([uo]l)>}) { |m| "#{$1}</p>\n<#{$2}>" }
        content
      end
    end

      # Produces block quotes.
    class Blockquotes < Ruwiki::Wiki::Token
      def self.regexp
        %r{^\\?(:+)\s+(.*)$}
      end

      def replace
        content = @match[2]
        indent  = @match[1].count(":")

        pre   = ""
        post  = ""
        indent.times do
          pre   << "<blockquote>"
          post  << "</blockquote>"
        end
        "#{pre}#{content}#{post}"
      end

      def restore
        @match[0][1 .. -1]
      end

      def self.post_replace(content)
        content.gsub!(%r{</blockquote>(\n|<br ?/?>)?<blockquote>}, '')
        content
      end
    end

      # Produces definition lists. Does not completely work correctly.
    class Definitions < Ruwiki::Wiki::Token
      def self.regexp
        %r{^\\?(;+)\s+([^:]+)\s+:\s+(.*)}
      end

      def replace
        definition  = @match[3]
        term        = @match[2]
        indent      = @match[1].count(';')

        pre   = ""
        post  = ""
        indent.times do
          pre   << "<dl>"
          post  << "</dl>"
        end
        "#{pre}<dt>#{term}</dt><dd>#{definition}</dd>#{post}"
      end

      def restore
        @match[0][1 .. -1]
      end

      def self.post_replace(content)
        content.gsub!(%r{</dl>(\n|<br ?/?>)?<dl>}, '')
        content
      end
    end
  end
end
