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
      # Converts headings.
    class Headings < Ruwiki::Wiki::Token
      def self.rank
        2
      end

      def self.regexp
        %r{^\\?(=+)\s+(.*)}
      end

      def restore
        @match[0][1 .. -1]
      end

      def replace
        level   = @match[1].count("=")
        content = @match[2]
        level   = 6 if level > 6
        "<h#{level}>#{content}</h#{level}>"
      end

      def post_replace(content)
        content.gsub!(%r{<p>(<h\d>)}, '\1')
        content.gsub!(%r{(</h\d>)</p>}, '\1')
        content
      end
    end
  end
end
