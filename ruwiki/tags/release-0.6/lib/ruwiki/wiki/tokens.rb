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
      # The base Token class. All Token classes must inherit from Token and
      # *must* implement the following methods:
      #
      # [self.regexp]   The regular expression that the Token will be
      #                 replacing.
      # [replace]       The mechanism for replacing the Token with the desired
      #                 results.
      #
      # Token classes <i>should</i> implement the following method:
      # [self.rank]     Default: <tt>5000</tt>. Affects the sort order. Must
      #                 return an integer.
      #
      # Token classes <i>may</i> implement the following methods:
      # [restore]       Restores the token without replacement. Implements the
      #                 results of the escape character. NOTE: each Token
      #                 class is responsible for its own restore. Tokens that
      #                 are anchored to the beginning of a line are the most
      #                 likely to need to reimplement this.
      # [post_replace]  Performs any necessary massaging of the data. See the
      #                 implementation of Ruwiki::Wiki::Lists for more
      #                 information.
    class Token
      @@tokenlist = []
      @@sorted    = false

      class << self
          # Tokens should define rank if they must be first or last in
          # processing. Otherwise, they are sorted in the order defined.
        def rank
          5000
        end

          # The Wiki parsing routine uses Token.tokenlist to determine the
          # tokens that are processed, and the order in which they are
          # processed. See Token.rank for more information.
        def tokenlist
          unless @@sorted
            head = @@tokenlist.shift
            @@tokenlist.sort! { |a, b| a.rank <=> b.rank }
            @@tokenlist.unshift(head)
            sorted = true
          end
          @@tokenlist
        end

        def inherited(child_class) #:nodoc:
          @@tokenlist << Token if @@tokenlist.empty?

            # Make the child class post_replace a blank function because we
            # don't want to propogate the currently defined post_replace.
            # The current post_replace is specific to Token_Base only.
          class << child_class
            def post_replace(content)
              content
            end
          end

          @@tokenlist << child_class
          @@sorted = false
        end

          # The replacement regular expression.
        def regexp
          /TOKEN_(\d*)/
        end
      end

        # All Token classes must match this header signature if they define
        # #initialize.
        #
        # [ruwiki]    The owner Ruwiki object.
        # [match]     The MatchData object for this Token.
        # [meta]      The metadata that may be stored by the Token.
        # [project]   The project being processed.
      def initialize(ruwiki, match, meta, project = nil)
        @ruwiki   = ruwiki
        @match    = match
        @meta     = meta
        @project  = project || @ruwiki.config.default_project
      end

        # The replacement method. Uses @match to replace the token with the
        # appropriate values.
      def replace
        "TOKEN_#{@match[1]}"
      end

        # Restores the token without replacement. By default, replaces
        # "dangerous" HTML characters.
      def restore
        @match[0].gsub(/&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
      end

        # The content may need massaging after processing.
      def post_replace(content)
        content
      end
    end
  end
end

  # Load the tokens from the ruwiki/wiki/tokens directory.
tokens_dir = 'ruwiki/wiki/tokens'

$LOAD_PATH.each do |path|
  target = "#{path}/#{tokens_dir}"
  if File.exists?(target) and File.directory?(target)
    Dir::glob("#{target}/*.rb") do |token|
      begin
        require token
      rescue LoadError
        nil
      end
    end
  end
end
