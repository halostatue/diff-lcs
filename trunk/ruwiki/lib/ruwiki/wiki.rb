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
    content = clean(content)
    tokens  = []
    project ||= @default_project

    Token.tokenlist.each do |token|
      content.gsub!(token.regexp) do |mm|
        match = Regexp.last_match
        tc = token.new(match, project, @backend, @script, @message, @title)
        tokens << tc
        if mm[0, 1] == '\\'
          "\\TOKEN_#{tokens.size - 1}"
        else
          "TOKEN_#{tokens.size - 1}"
        end
      end
    end

    replaced = []
    ss = true
    loop do
      break if replaced.size >= tokens.size
      break if ss.nil?
      ss = content.gsub!(/\\TOKEN_(\d+)/) { |mm|
        match   = Regexp.last_match
        itoken  = match[1].to_i
        replaced << itoken
        tokens[itoken].restore
      }

      ss = content.gsub!(/TOKEN_(\d+)/) { |mm|
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

    # A regular expression that will prevent redirection.
  class << self
    attr_accessor :no_redirect

    def redirect(uri)
      if uri =~ %r{^https?://}
        if self.no_redirect and uri =~ self.no_redirect
          uri
        else
          "http://www.google.com/url?sa=D&amp;q=#{CGI.escape(uri)}"
        end
      else
        uri
      end
    end
  end

private
    # Find HTML tags
  SIMPLE_TAG_RE = %r{<[^<>]+?>}   # Ensure that only the tag is grabbed.
  HTML_TAG_RE   = %r{\A<          # Tag must be at start of match.
                        (/)?      # Closing tag?
                        ([\w:]+)  # Tag name
                        (?:\s+    # Space
                         ([^>]+)  # Attributes
                         (/)?     # Singleton tag?
                        )?        # The above three are optional
                       >}x
  ATTRIBUTES_RE = %r{([\w:]+)(=(?:\w+|"[^"]+?"|'[^']+?'))?}x
  STYLE_NOVD_RE = %r{(?:\s?(visibility|display):[^'";]+;?)}x
  ALLOWED_ATTR  = %w(style title type lang dir class id cite datetime abbr) +
                  %w(colspan rowspan compact start media)
  ALLOWED_HTML  = %w(abbr acronym address b big blockquote br caption cite) +
                  %w(code col colgroup dd del dfn dir div dl dt em h1 h2 h3) +
                  %w(h4 h5 h6 hr i ins kbd li menu ol p pre q s samp small) +
                  %w(span strike strong style sub sup table tbody td tfoot) +
                  %w(th thead tr tt u ul var)

    # Clean the content of unsupported HTML and attributes. This includes
    # XML namespaced HTML. Sorry, but there's too much possibility for
    # abuse.
  def clean(content)
    content = content.gsub(SIMPLE_TAG_RE) do |tag|
      tagset = HTML_TAG_RE.match(tag)

      if tagset.nil?
        tag = Ruwiki.clean_entities(tag)
      else
        closer, name, attributes, single = tagset.captures

        if ALLOWED_HTML.include?(name.downcase)
          unless closer or attributes.nil?
            attributes = attributes.scan(ATTRIBUTES_RE).map do |set|
              if ALLOWED_ATTR.include?(set[0].downcase)
                if set[0] == 'style'
                  set[1].gsub!(STYLE_NOVD_RE, '')
                end
                set.join
              else
                nil
              end
            end.compact.join(" ")
            tag = "<#{closer}#{name} #{attributes}#{single}>"
          else
            tag = "<#{closer}#{name}>"
          end
        else
          tag = Ruwiki.clean_entities(tag)
        end
      end
      tag.gsub(%r{((?:href|src)=["'])(#{Ruwiki::Wiki::RE_URI_SCHEME})}) { "#{$1}\\#{$2}" }
    end
  end
end

require 'ruwiki/wiki/tokens'
