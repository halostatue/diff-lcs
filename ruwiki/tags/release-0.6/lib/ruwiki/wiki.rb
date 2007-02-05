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
require 'ruwiki/markup'

class Ruwiki
    # Ruwiki's Wiki markup class. This will convert the Wiki markup known by
    # Ruwiki (defined by Token classes). The algorithm is as follows:
    #
    # 1.  For each known Token class, match each instance of it in the content
    #     stream. Replace each instance in the content stream with a Token
    #     marker: TOKEN_x or \TOKEN_x, where x is a digit representing the
    #     Token. (\TOKEN_x is a special case of token matching. See
    #     Ruwiki::Markup::Token for more information.) Store the Token for
    #     later processing.
    # 2.  Go back through the content, replacing each instance of \TOKEN_x
    #     with the Token's defined restore value (which should be the same
    #     value as was originally matched).
    # 3.  Go through the content, replacing each instance of TOKEN_x with the
    #     Token's defined replacement value.
    # 4.  Go through the tokens, in reverse, and execute the post replacement
    #     routine defined by the Token. (This may be necessary to collapse
    #     consecutive HTML structures.)
    # 5.  Return the parsed content and the collected metadata.
    #
    # == Tokens
    # Look at Ruwiki::Markup::Token describes how to create Token objects.
  class Wiki < Ruwiki::Markup
    def parse(content, project = nil)
      content = content.dup
      meta    = Ruwiki::Markup::Meta.new(@ruwiki)
      tokens  = []
      project ||= @ruwiki.config.default_project

      Token.tokenlist.each do |token|
        content.gsub!(token.regexp) do |m|
          match = Regexp.last_match
          tc = token.new(@ruwiki, match, meta, project)
          tokens << tc
          if m[0, 1] == '\\'
            "\\TOKEN_#{tokens.size - 1}"
          else
            "TOKEN_#{tokens.size - 1}"
          end
        end
      end

      replaced = []
      s = true
      loop do
        break if replaced.size >= tokens.size
        break if s.nil?
        s = content.gsub!(/\\TOKEN_(\d+)/) { |m|
          match   = Regexp.last_match
          itoken  = match[1].to_i
          replaced << itoken
          tokens[itoken].restore
        }

        s = content.gsub!(/TOKEN_(\d+)/) { |m|
          match   = Regexp.last_match
          itoken  = match[1].to_i
          replaced << itoken
          tokens[itoken].replace
        }
      end

      3.times do
        tokens.reverse_each { |token| token.post_replace(content) }
      end

      [content, meta]
    end
  end
end

require 'ruwiki/wiki/tokens'
