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
require 'ruwiki/markup/meta'

class Ruwiki
    # The abstract markup class. Probably unnecessary.
  class Markup
      # Creates the markup class.
    def initialize(ruwiki)
      @ruwiki = ruwiki
    end

      # Returns a topic/projec combination as a viewable link.
    def view_link(topic, project, content = nil)
      content = topic if content.nil?
      project = (project == @ruwiki.config.default_project) ? "" : "#{project}/"
      %Q{<a class="rw_pagelink" href="#{@ruwiki.request.script_url}/#{project}#{topic}">#{content.gsub(/_/, ' ')}</a>}
    end

      # Returns a topic/projec combination as an edit link.
    def edit_link(topic, project, content = nil)
      content = topic if content.nil?
      project = (project == @ruwiki.config.default_project) ? "" : "project=#{project}&amp;"
      %Q{<span class="rw_edittext">#{content.gsub(/_/, ' ')}</span><a class="rw_pagelink" href="#{@ruwiki.request.script_url}?action=edit&amp;#{project}#{topic}">?</a>}
    end
  end
end
