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
require 'cgi'

class Ruwiki
  class Wiki
      # This provides the basic WikiWord match. This supports WikiWord,
      # CPlusPlus, ThisIsALink, and C_Plus_Plus.
    RE_WIKI_WORDS       = %r{[[:upper:]][\w_]*(?:[[:lower:]]+[[:upper:]_]|[[:upper:]_]+[[:lower:]])[\w_]*}
      # This provides wikipedia format matches, e.g., [[wikipedia links]].
    RE_WIKIPEDIA_WORDS  = %r{\[\[(.+?)\]\]}
      # This provides the basic Wiki Project match.
    RE_PROJECT_WORD     = %r{[[:upper:]][[:lower:]]+}

      # This provides the Wiki view link format:
    VIEW_LINK = %Q[<a class="rw_pagelink" href="%s">%s</a>]
    EDIT_LINK = %Q[<span class="rw_edittext">%s</span><a class="rw_pagelink" href="%s">?</a>]

      # Creates a crosslink for a Project::WikiPage.
    class ProjectCrossLink < Ruwiki::Wiki::Token
      def self.rank
        502
      end

      def self.regexp
        %r{(#{RE_PROJECT_WORD})::(#{RE_WIKI_WORDS})}
      end

      def replace
        captures = @match.captures
        project = captures[0]
        topic   = captures[1]
        link    = CGI.escape(topic.dup)

        if @ruwiki.backend.page_exists?(topic, project)
          VIEW_LINK % ["#{@ruwiki.request.script_url}/#{project}/#{link}", "#{project}::#{topic.gsub(/_/, ' ')}"]
        else
          EDIT_LINK % ["#{project}::#{topic.gsub(/_/, ' ')}", "#{@ruwiki.request.script_url}/#{project}/#{link}/edit"]
        end
      end
    end

    class ProjectCrossLinkWikipedia < Ruwiki::Wiki::Token
      def self.rank
        502
      end

      def self.regexp
        %r{(#{RE_PROJECT_WORD})::(#{RE_WIKIPEDIA_WORDS})}
      end

      def replace
        captures = @match.captures
        project = captures[0]
        link    = CGI.escape(captures[1])
        topic   = captures[2]

        if @ruwiki.backend.page_exists?(topic, project)
          VIEW_LINK % ["#{@ruwiki.request.script_url}/#{project}/#{link}", "#{project}::#{topic}"]
        else
          EDIT_LINK % ["#{project}::#{topic}", "#{@ruwiki.request.script_url}/#{project}/#{link}/edit"]
        end
      end
    end

      # Creates a link to the project index from ::Project.
    class ProjectIndex < Ruwiki::Wiki::Token
      def self.rank
        501
      end

      def self.regexp
        %r{(\B|\\)::(#{RE_PROJECT_WORD})}
      end

      def restore
        @match[0][1..-1]
      end

      def replace
        project = @match.captures[1]

        if @ruwiki.backend.page_exists?('ProjectIndex', project)
          VIEW_LINK % ["#{@ruwiki.request.script_url}/#{project}/ProjectIndex", project]
        else
          if @ruwiki.backend.project_exists?(project)
            EDIT_LINK % [project, "#{@ruwiki.request.script_url}/#{project}/ProjectIndex/edit"]
          else
            EDIT_LINK % [project, "#{@ruwiki.request.script_url}/#{project}/create"]
          end
        end
      end
    end

      # Creates a link to a WikiPage in the current project.
    class WikiLinks < Ruwiki::Wiki::Token
      def self.rank
        503
      end

      def self.regexp
        %r{(\b|\\)(#{RE_WIKI_WORDS})\b}
      end

      def restore
        @match[0][1..-1]
      end

      def replace
        topic = @match.captures[1]
        link  = CGI.escape(topic.dup)

        if @ruwiki.backend.page_exists?(topic, project)
          VIEW_LINK % ["#{@ruwiki.request.script_url}/#{@project}/#{link}", "#{@project}::#{topic.gsub(/_/, ' ')}"]
        else
          EDIT_LINK % ["#{@project}::#{topic.gsub(/_/, ' ')}", "#{@ruwiki.request.script_url}/#{@project}/#{link}/edit"]
        end
      end
    end

    class WikipediaLinks < Ruwiki::Wiki::Token
      def self.rank
        503
      end

      def self.regexp
        %r{(\b|\\)(#{RE_WIKIPEDIA_WORDS})\b}
      end

      def restore
        @match[0][1..-1]
      end

      def replace
        captures = @match.captures
        link     = CGI.escape(captures[1])
        topic    = captures[2]

        if @ruwiki.backend.page_exists?(topic, project)
          VIEW_LINK % ["#{@ruwiki.request.script_url}/#{@project}/#{link}", "#{@project}::#{topic}"]
        else
          EDIT_LINK % ["#{@project}::#{topic}", "#{@ruwiki.request.script_url}/#{@project}/#{link}/edit"]
        end
      end
    end
  end
end
