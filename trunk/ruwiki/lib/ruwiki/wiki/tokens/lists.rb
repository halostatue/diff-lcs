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
    # Produces Lists
  class Lists < Ruwiki::Wiki::Token
    def self.regexp
      %r{^\\?([*#]+)\s+(.*)$}
    end

    def replace
      indent  = @match.captures[0].scan(/./).map { |ee| ee == "*" ? 'ul' : 'ol' }
      content = @match.captures[1]

      pre   = ''
      post  = ''
      indent.each { |elem| pre << %Q(<#{elem} class="rwtk_Lists">) }
      indent.reverse_each { |elem| post << %Q(</#{elem}>) }
      %Q(#{pre}<li class="rwtk_Lists">#{content}</li>#{post})
    end

    def restore
      @match[0][1 .. -1]
    end

    RE_NESTED_LISTS = %r{</[uo]l>\s*<[uo]l[^>]*>}

    def self.post_replace(content)
      content.gsub!(%r{<p[^>]*><([uo]l[^>]*)>}, '<\1>')
      content.gsub!(%r{</([uo]l)></p>}, '</\1>')
      content.gsub!(RE_NESTED_LISTS, '') while content =~ RE_NESTED_LISTS
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
        pre   << %Q(<blockquote#{cite} class="rwtk_Blockquotes">)
        post  << %Q(</blockquote>)
      end
      "#{pre}#{content}#{post}"
    end

    def restore
      @match[0][1 .. -1].gsub(/^>/, '&gt;')
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
        pre   << %Q(<dl class="rwtk_Definitions">)
        post  << %Q(</dl>)
      end
      %Q(#{pre}<dt class="rwtk_Definitions">#{term}</dt><dd class="rwtk_Definitions">#{definition}</dd>#{post})
    end

    def restore
      @match[0][1 .. -1]
    end

    def self.post_replace(content)
      content.gsub!(%r{</dl>(\n|<br ?/?>)?<dl[^>]*>}, '')
      content.gsub!(%r{</dl>(<dl[^>]*>)+}, '\1')
      content
    end
  end
end
