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
      # Convert ruby-talk mailing list references (e.g., [ruby-talk:12345])
      # into named links.
    class RubyTalkLinks < Ruwiki::Wiki::Token
      def self.rank
        2
      end

      def self.regexp
        %r{\[ruby-talk:(\d+)\]}
      end

      def replace
        lm = @match.captures[0]
        %Q(<a class="rw_extlink" href="http://www.ruby-talk.org/#{lm}">#{@match[0]}</a>)
      end
    end

      # Convert ruby-core/ext/dev/list/math mailing list references (e.g.,
      # [ruby-core:12345]) into named links.
    class OtherRubyLinks < Ruwiki::Wiki::Token
      def self.rank
        2
      end

      def self.regexp
        %r{\[ruby-(list|doc|core|dev|ext|math):(\d+)\]}
      end

      def replace
        ln, lm = @match.captures[0..1]
        %Q(<a class="rw_extlink" href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-#{ln}/#{lm}">#{@match[0]}</a>)
      end
    end
  end
end
