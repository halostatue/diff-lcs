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
      # Converts abbreviations.
    class Abbreviations < Ruwiki::Wiki::Token
      def self.regexp
        %r!@{([^}]*)}!
      end

      def replace
        k = @match[1]
        if k.nil? or k.empty?
          data = "<dl>"
          @ruwiki.abbr.each do |k, v|
            data << "<dt>#{k}</dt><dd>#{v}</dd>"
          end
          data << "</dl>"
        else
          if @ruwiki.abbr.has_key?(k)
            data = @ruwiki.abbr[k]
          else
            data = @match[0]
          end
        end
        data
      end
    end
  end
end
