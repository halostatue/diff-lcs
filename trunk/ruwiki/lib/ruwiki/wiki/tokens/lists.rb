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
class Ruwiki
  class Wiki
      # Produces Lists
    class Lists < Ruwiki::Wiki::Token
      def self.regexp
        %r{^\\?((\*)+|(#)+)\s+(.*)}
      end

      def replace
        content = @match.captures[3]

        if @match.captures[2].nil?
          char = '*'
          elem = 'ul'
        else
          char = '#'
          elem = 'ol'
        end

        indent = @match.captures[0].count(char)

        pre   = ''
        post  = ''
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
        content.gsub!(%r{</ol>(\n|<br ?/?>)?<ol>}, '')
        content.gsub!(%r{</ul>(\n|<br ?/?>)?<ul>}, '')
        content.gsub!(%r{<li><([uo]l)>}, '<\1>')
        content.gsub!(%r{</li><li>}, "</li>\n<li>")
        content.gsub!(%r{</([uo]l)></li>}, '</\1>')
        content.gsub!(%r{([^>])\n<([uo]l)>}) { |m| "#{$1}</p>\n<#{$2}>" }
        content.gsub!(%r{</ol><ol>}, '')
        content.gsub!(%r{</ul><ul>}, '')
        content
      end
    end

      # Produces block quotes.
    class Blockquotes < Ruwiki::Wiki::Token
      def self.regexp
        %r{^\\?((:+)|(>+))(\s+.*)$}
      end

      def replace
        content = @match.captures[3]

        if @match.captures[2].nil?
          char = ':'
          cite = ''
        else
          char = '>'
          cite = ' type="cite"'
        end
        indent  = @match.captures[0].count(char)

        pre   = ''
        post  = ''
        indent.times do
          pre   << "<blockquote#{cite}>"
          post  << "</blockquote>"
        end
        "#{pre}#{content}#{post}"
      end

      def restore
        @match[0][1 .. -1]
      end

      def self.post_replace(content)
        content.gsub!(%r{</blockquote>(\n|<br ?/?>)?<blockquote[^>]*>}, '')
        content.gsub!(%r{(</?blockquote[^>]*>\n?)\s*}, '\1')
        content.gsub!(%r{</blockquote>(<blockquote[^>]*>)+}, '\1')
        content
      end
    end

      # Produces definition lists. Does not completely work correctly.
    class Definitions < Ruwiki::Wiki::Token
      def self.regexp
        %r{^\\?(;+)\s+([^:]+)\s+:\s+(.*)}
      end

      def replace
        definition  = @match.captures[2]
        term        = @match.captures[1]
        indent      = @match.captures[0].count(';')

        pre   = ''
        post  = ''
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
        content.gsub!(%r{</dl>(<dl>)+}, '\1')
        content
      end
    end
  end
end
