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
require 'webrick'

class Ruwiki
  class Servlet < WEBrick::HTTPServlet::AbstractServlet
    def initialize(config)
      @config = config
    end

      # Converts a POST into a GET.
    def do_POST(req, res)
      do_GET(req, res)
    end

    def do_GET(req, res)
        # Generate the reponse handlers for Ruwiki from the request and response
        # objects provided.
      wiki = Ruwiki.new(Ruwiki::Handler.from_webrick(req, res))

        # Configuration defaults to certain values. This overrides the defaults.
      wiki.config = $config unless $config.nil?
      wiki.run
    end
  end
end
