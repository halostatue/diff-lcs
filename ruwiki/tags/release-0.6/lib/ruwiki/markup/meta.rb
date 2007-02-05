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
  class Markup
      # Stores metadata generated during the parsing process.
    class Meta
        # links to external sites
      attr_reader :external
        # links to internal sites
      attr_reader :internal

        # Initializes the metadata object.
      def initialize(ruwiki)
        @ruwiki   = ruwiki
        @internal = []
        @external = []
      end

        # Adds a link to the appropriate bucket in the metadata.
      def add_link(link, style = :internal)
        if style == :internal
          @internal << link unless @internal.include?(link)
        elsif style == :external
          @external << link unless @external.include?(link)
        end
      end
    end
  end
end
