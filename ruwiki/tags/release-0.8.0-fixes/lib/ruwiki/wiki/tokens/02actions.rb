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
require 'cgi'

class Ruwiki::Wiki
    # Produces a list of topics.
  class TopicList < Ruwiki::Wiki::Token
    def self.regexp
      %r{^%topics\((#{Ruwiki::Wiki::RE_PROJECT_WORD})?\)$}
    end

    def replace
      project = @match.captures[0] || @project

      if @backend.project_exists?(project)
        topic_list = @backend.list_topics(project)
      else
        topic_list = []
      end

      if topic_list.empty?
        s = @message[:no_topics] % [project]
      else
        s = %Q(<h4 class="rwtk_Headings">#{@message[:topics_for_project] % [project]}</h4>\n<ul class="rwtk_Lists">\n)
        topic_list.each do |tt|
          s << %Q(<li class="rwtk_Lists">)
          s << VIEW_LINK % ["#{@script}/#{project}/#{tt}", "#{CGI::unescape(tt.gsub(/_/, ' '))}"]
          s << "</li>\n"
        end
        s << "</ul>\n"
      end

      s
    end
  end

  class ProjectList < Ruwiki::Wiki::Token
    def self.regexp
      %r{^%projects\(\)$}
    end

    def replace
      proj_list = @backend.list_projects

      s = %Q(<h4 class="rwtk_Headings">#{@message[:wiki_projects] % [@title]}</h4>\n<ul class="rwtk_Lists">\n)
      proj_list.each do |pp|
        s << %Q(<li class="rwtk_Lists">)
        s << VIEW_LINK % ["#{@script}/#{pp}/ProjectIndex", pp]
        s << %Q! <a href='#{@script}/#{pp}/_topics' class='rw_minilink'>#{@message[:project_topics_link]}</a>!
        s << "</li>\n"
      end
      s << "</ul>\n"
    end
  end
end
