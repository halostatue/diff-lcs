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
      ABBREVIATIONS = {
        "PM"  =>  "PocoMail"
      }

      def self.regexp
        %r!@\{([^\}]*)\}!
      end

      def replace
        k = @match.captures[0]
        if k.nil? or k.empty?
          data = "<dl>"
          ABBREVIATIONS.each do |k, v|
            data << "<dt>#{k}</dt><dd>#{v}</dd>"
          end
          data << "</dl>"
        else
          if ABBREVIATIONS.has_key?(k)
            data = ABBREVIATIONS[k]
          else
            data = @match[0]
          end
        end
        data
      end
    end
  end
end
