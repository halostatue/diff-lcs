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
class Ruwiki::Wiki
    # Converts abbreviations.
  class Abbreviations < Ruwiki::Wiki::Token
    ABBREVIATIONS = {
      "matz"  => "Yukihiro Matsumoto",
    }

    def self.regexp
      %r!@\{([^\}]*)\}!
    end

    def replace
      k = @match.captures[0]
      if k.nil? or k.empty?
        data = %Q(<dl class="rwtk_Abbreviations">)
        ABBREVIATIONS.each do |k, v|
          data << %Q(<dt class="rwtk_Abbreviations">#{k}</dt><dd class="rwtk_Abbreviations">#{v}</dd>)
        end
        data << %Q(</dl>)
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
