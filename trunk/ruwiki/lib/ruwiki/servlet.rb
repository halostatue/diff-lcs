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

class Ruwiki::Servlet < WEBrick::HTTPServlet::AbstractServlet
  class << self
    attr_accessor :config
  end

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
    wiki.config = Ruwiki::Servlet.config unless Ruwiki::Servlet.config.nil?
    wiki.config!
    wiki.config.logger = @config.logger
    wiki.run
  end
end
