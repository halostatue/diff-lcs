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
  # Ruwiki's Wiki markup class. This will convert the Wiki markup known by
  # Ruwiki (defined by Token classes). The algorithm is as follows:
  #
  # 1.  For each known Token class, match each instance of it in the content
  #     stream. Replace each instance in the content stream with a Token
  #     marker: TOKEN_x or \TOKEN_x, where x is a digit representing the Token.
  #     (\TOKEN_x is a special case of token matching. See
  #     Ruwiki::Markup::Token for more information.) Store the Token for later
  #     processing.
  # 2.  Go back through the content, replacing each instance of \TOKEN_x with
  # the Token's defined restore value (which should be the same value as was
  # originally matched).
  # 3.  Go through the content, replacing each instance of TOKEN_x with the
  # Token's defined replacement value.
  # 4.  Go through the tokens, in reverse, and execute the post replacement
  # routine defined by the Token. (This may be necessary to collapse
  # consecutive HTML structures.)
  # 5.  Return the parsed content and the collected metadata.
  #
  # == Tokens
  # Look at Ruwiki::Markup::Token describes how to create Token objects.
class Ruwiki::Wiki
  def parse(content, project)
    content = content.dup
    tokens  = []
    project ||= @default_project

    Token.tokenlist.each do |token|
      content.gsub!(token.regexp) do |m|
        match = Regexp.last_match
        tc = token.new(match, project, @backend, @script, @message, @title)
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

    token_classes = tokens.map { |token| token.class }.sort_by { |token| token.rank }
    token_classes.uniq.each { |tc| tc.post_replace(content) }

    content
  end

  attr_accessor :default_project
  attr_accessor :script
  attr_accessor :backend
  attr_accessor :message

    # Creates the markup class.
  def initialize(default_project, script, title)
    @default_project  = default_project
    @script           = script
    @title            = title
  end
end

require 'ruwiki/wiki/tokens'
