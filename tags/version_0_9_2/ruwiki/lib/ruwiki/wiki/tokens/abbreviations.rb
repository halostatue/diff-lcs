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
      kk = @match.captures[0]
      if kk.nil? or kk.empty?
        data = %Q(<dl class="rwtk_Abbreviations">)
        ABBREVIATIONS.each do |kk, vv|
          data << %Q(<dt class="rwtk_Abbreviations">#{kk}</dt><dd class="rwtk_Abbreviations">#{vv}</dd>)
        end
        data << %Q(</dl>)
      else
        if ABBREVIATIONS.has_key?(kk)
          data = ABBREVIATIONS[kk]
        else
          data = @match[0]
        end
      end
      data
    end
  end
end
