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
      # The Paragraph Token class changes blank lines to <p> tags. This class,
      # under the current implementation, should be *first* in the Token list
      # after Token.
    class Paragraph < Ruwiki::Wiki::Token
        # This Token is #rank 0, because it should be first in the Token list.
      def self.rank
        0
      end

        # Matches blank lines. %r{^\s*$}
      def self.regexp
        %r{^\s*$}
      end

        # Replaces with "<p>"
      def replace
        "<p>"
      end

        # Ensures that <p> won't be surrounded by <br> tags.
      def post_replace(content)
        content.gsub!(%r{(\n|<br ?/?>)?<p>(\n|<br ?/?>)?}, '<p>')
        content.gsub!(%r{<p>}, '</p><p>')
        content.gsub!(%r{</p>(</p>)+}, '</p>')
        content.gsub!(%r{<body></p>}, '<body>')
        content.gsub!(%r{</body>}, '</p></body>')
        content.gsub!(%r{<p></p>}, '')
        content.gsub!(%r{(</h\d>)</p>}, '\1')
        content
    end
  end

      # The Code Token class converts indented text to "unformatted" (<pre>)
      # text. This class should be *second* in the Token list.
    class Code < Ruwiki::Wiki::Token
        # This Token is #rank 1, because it should be second in the Token list.
      def self.rank
        1
      end

        # Matches indented text. %r{^(\s+\S.*)$}
      def self.regexp
        %r{^(\s+\S.*)$}
      end

        # Replaces the text to <pre>content</pre>.
      def replace
        content = @match[1].gsub(/&/) { "&amp;" }.gsub(/</) { "&lt;" }.gsub(/>/) { "&gt;" }
        %Q{<pre>#{content}</pre>}
      end

        # Converts cases of %r{</pre>(\n|<br ?/?>)<pre>} to \1.
      def post_replace(content)
        content.gsub!(%r{</pre>(\n|<br ?/?>)?<pre>}, '\1')
        content.gsub!(%r{<p><pre>}, '<pre>')
        content.gsub!(%r{</pre></p>}, '</pre>')
        content
      end
    end

      # Converts URLs in the form of [url] to numbered links.
    class NumberedLinks < Ruwiki::Wiki::Token
      def self.rank
        2
      end

      def initialize(ruwiki, match, parse, project = nil)
        super
        @@count = 0
      end

      def self.regexp
        %r{\[((https?|ftp|mailto|news):[^\s<>\]]*?)\]}
      end

      IMAGE_RE = /(jpg|jpeg|png|gif)$/

      def replace
        extlink = @match[1]

        @@count += 1
        name = "[#{@@count}]"

        if extlink =~ IMAGE_RE
          %Q{<img src="#{extlink}" title="#{name}" alt="#{name}" />}
        else
          @meta.add_link(extlink, :external)
          %Q{<a class="rw_extlink" href="#{extlink}">#{name}</a>}
        end
      end
    end

      # Converts URLs in the form of [url name] to named links.
    class NamedLinks < Ruwiki::Wiki::Token
      def self.rank
        3
      end

      def self.regexp
        %r{\[(((https?)|(ftp)|(mailto)|(news)):[^\s<>]*)\s+([^\]]*)\]}
      end

      IMAGE_RE = /(jpg|jpeg|png|gif)$/

      def replace
        extlink = @match[1]
        name    = @match[7]

        if extlink =~ IMAGE_RE
          %Q{<img src="#{extlink}" title="#{name}" alt="#{name}" />}
        else
          @meta.add_link(extlink, :external)
          %Q{<a class="rw_extlink" href="#{extlink}">#{name}</a>}
        end
      end
    end

      # Converts URLs to links where the "name" of the link is the URL itself.
    class ExternalLinks < Ruwiki::Wiki::Token
      def self.rank
        4
      end

      def self.regexp
        %r{\b((https?|ftp|mailto|news):[^\s<>]*)}
      end

      IMAGE_RE = /(jpg|jpeg|png|gif)$/

      def replace
        extlink = @match[1]

        if extlink =~ IMAGE_RE
          %Q{<img src="#{extlink}" title="Image at: #{extlink}" alt="Image at: #{extlink}" />}
        else
          @meta.add_link(extlink, :external)
          %Q{<a class="rw_extlink" href="#{extlink}">#{extlink}</a>}
        end
      end
    end

      # Creates a crosslink for a Project::WikiPage.
    class ProjectCrossLink < Ruwiki::Wiki::Token
      def self.rank
        502
      end

      def self.regexp
        %r{([A-Z][a-z]+)::([A-Z][a-z]+([A-Z][a-z]+)+)}
      end

      def replace
        project = @match[1]
        topic   = @match[2]

        return @ruwiki.markup.edit_link(topic, project, "#{project}::#{topic}") unless @ruwiki.backend.page_exists?(topic, project)
        @ruwiki.markup.view_link(topic, project, "#{project}::#{topic}")
      end
    end

      # Creates a link to the project index from ::Project.
    class ProjectIndex < Ruwiki::Wiki::Token
      def self.rank
        501
      end

      def self.regexp
        %r{(\B|\\)::([A-Z][a-z]+)}
      end

      def restore
        @match[0][1..-1]
      end

      def replace
        pn = @match.captures[1]
        %Q(<a class="rw_projectindex" href="#{@ruwiki.request.script_url}/#{pn}/ProjectIndex">#{pn}</a>)
      end
    end

      # Creates a link to a WikiPage in the current project.
    class WikiLinks < Ruwiki::Wiki::Token
      def self.rank
        503
      end

      def self.regexp
        %r{(\b|\\)([A-Z][a-z]+([A-Z][a-z]+|_[A-Z]?[a-z]+)+)\b}
      end

      def restore
        @match[0][1..-1]
      end

      def replace
        topic = @match.captures[1]
        @meta.add_link(topic)
        if @ruwiki.backend.page_exists?(topic, @project)
          @ruwiki.markup.view_link(topic, @project)
        else
          @ruwiki.markup.edit_link(topic, @project)
        end
      end
    end

      # Creates a horizontal rule.
    class HRule < Ruwiki::Wiki::Token
      def self.regexp
        %r|^\\?-{4,}|
      end

      def replace
        "<hr />"
      end

      def restore
        @match[0][1 .. -1]
      end

      def post_replace(content)
        content.gsub!(%r{<hr ?/?>\n<br ?/?>}, "<hr />")
        content.gsub!(%r{(\n|<br ?/?>)?<hr>(\n|<br ?/?>)?}, "<hr />")
        content
      end
    end
  end
end
