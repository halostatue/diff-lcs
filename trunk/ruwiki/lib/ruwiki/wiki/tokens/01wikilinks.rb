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
    # This provides the basic WikiWord match. This supports WikiWord,
    # CPlusPlus, ThisIsALink, and C_Plus_Plus.
  RE_WIKI_WORDS       = %r{[[:upper:]][\w_]*(?:[[:lower:]]+[[:upper:]_]|[[:upper:]_]+[[:lower:]])[\w_]*}
    # This provides wikipedia format matches, e.g., [[wikipedia links]]. The
    # only restriction on words in this format is that they must NOT begin
    # with an underscore ('_').
  RE_WIKIPEDIA_WORDS  = %r{\[\[([^_].*?)\]\]}
    # This provides the basic Wiki Project match.
  RE_PROJECT_WORD     = %r{[[:upper:]][[:lower:]]+}

    # This provides the Wiki view link format:
  VIEW_LINK = %Q[<a class="rwtk_WikiLink" href="%s">%s</a>]
  EDIT_LINK = %Q[<span class="rwtk_EditWikiLink">%s</span><a class="rwtk_WikiLink" href="%s">?</a>]

    # Creates a crosslink for a Project::WikiPage.
  class ProjectCrossLink < Ruwiki::Wiki::Token
    def self.rank
      500
    end

    def self.regexp
      %r{(#{RE_PROJECT_WORD})::(#{RE_WIKI_WORDS})}
    end

    def replace
      project = @match.captures[0]
      topic   = @match.captures[1]
      link    = CGI.escape(topic.dup)

      if @backend.page_exists?(topic, project) or @backend.page_exists?(link, project)
        VIEW_LINK % ["#{@script}/#{project}/#{link}", "#{project}::#{topic.gsub(/_/, ' ')}"]
      else
        EDIT_LINK % ["#{project}::#{topic.gsub(/_/, ' ')}", "#{@script}/#{project}/#{link}/_edit"]
      end
    end
  end

    # Creates a crosslink for a Project::WikiPage using a Wikipedia link
    # format.
  class ProjectCrossLinkWikipedia < Ruwiki::Wiki::Token
    def self.rank
      500
    end

    def self.regexp
      %r{(#{RE_PROJECT_WORD})::#{RE_WIKIPEDIA_WORDS}}
    end

    def replace
      project = @match.captures[0]
      topic   = @match.captures[1]
      link    = CGI.escape(topic)

      if @backend.page_exists?(topic, project) or @backend.page_exists?(link, project)
        VIEW_LINK % ["#{@script}/#{project}/#{link}", "#{project}::#{topic}"]
      else
        EDIT_LINK % ["#{project}::#{topic}", "#{@script}/#{project}/#{link}/_edit"]
      end
    end
  end

    # Creates a link to the project index from ::Project.
  class ProjectIndex < Ruwiki::Wiki::Token
    def self.rank
      501
    end

    def self.regexp
      %r{(\B|\\)::(#{RE_PROJECT_WORD})\b}
    end

    def restore
      @match[0][1..-1]
    end

    def replace
      project = @match.captures[1]

      if @backend.page_exists?('ProjectIndex', project) or @backend.page_exists?(link, project)
        VIEW_LINK % ["#{@script}/#{project}/ProjectIndex", project]
      else
        if @backend.project_exists?(project)
          EDIT_LINK % [project, "#{@script}/#{project}/ProjectIndex/_edit"]
        else
          EDIT_LINK % [project, "#{@script}/#{project}/_create"]
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

      if @backend.page_exists?(topic, @project) or @backend.page_exists?(link, project)
        VIEW_LINK % ["#{@script}/#{@project}/#{link}", topic.gsub(/_/, ' ')]
      else
        EDIT_LINK % [topic.gsub(/_/, ' '), "#{@script}/#{@project}/#{link}/_edit"]
      end
    end
  end

    # Creates a link to a WikiPage in the current project using a Wikipedia
    # link format.
  class WikipediaLinks < Ruwiki::Wiki::Token
    def self.rank
      502
    end

    def self.regexp
      %r{(\B|\\)#{RE_WIKIPEDIA_WORDS}\B}
    end

    def restore
      @match[0][1..-1]
    end

    ALT_TEXT = %r{(.+)\|(.+)}o

    def replace
      captures = @match.captures
      topic = @match.captures[1]
      link  = CGI.escape(topic)

      at = ALT_TEXT.match(topic)
      
      if not at.nil?
        topic = at.captures[1]
        link  = CGI.escape(at.captures[0])
      end

      if @backend.page_exists?(link, @project) or @backend.page_exists?(link, project)
        VIEW_LINK % ["#{@script}/#{@project}/#{link}", topic]
      else
        EDIT_LINK % [topic, "#{@script}/#{@project}/#{link}/_edit"]
      end
    end
  end
end
