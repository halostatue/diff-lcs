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
    # A generic page for Ruwiki.
  class Page
      # The page ID.
    attr_accessor :page_id
      # The current version of the page.
    attr_accessor :version
      # The previous version of the page.
    attr_accessor :old_version
      # The page topic (the name of the page).
    attr_accessor :topic
      # The project of the page.
    attr_accessor :project
      # Unformatted page text.
    attr_reader   :content
      # Formatted page text.
    attr_accessor :formatted

      # The IP address of the person who made the last change.
    def change_ip
      %Q<#{@ruwiki.request.environment['REMOTE_HOST']} (#{@ruwiki.request.environment['REMOTE_ADDR']})>
    end

      # The ID, if present, of the person who made the last change. Not yet
      # implemented.
    def change_id
      nil
    end

      # Creates a Ruwiki page.
    def initialize(ruwiki, init = {})
      @ruwiki = ruwiki

      @project      = init[:project] || @ruwiki.config.default_project
      @topic        = init[:topic] || "NewTopic"
      @content      = init[:content] || ""
      @page_id      = init[:page_id] || 0
      @version      = init[:version] || 0
      @old_version  = @version - 1

      if init.has_key?(:rawtext)
        @rawtext    = init[:rawtext].dup
        @content    = parse_header(@rawtext.dup)
        @formatted  = parse_content(@content, @project)
      elsif not @content.empty?
        @formatted  = parse_content(@content.dup, @project)
      else
        @formatted  = ""
      end
      @content.gsub!(/\r/, "")
    end

      # The content of the page.
    def content=(content)
      @content    = content.gsub(/\r/, "")
      @formatted  = parse_content(content, @project)
    end

      # Output raw header and raw page context for saving.
    def rawtext
      return <<-EOS
id: #{@page_id}
topic: #{@topic}
version: #{@version}
#EHDR
#{@content}
      EOS
    end

      # Outputs the HTML version of the page.
    def to_html
      @formatted
    end

  private
    HEADER_RE     = /^([a-z]+)\s*:\s*(.*)$/
    HEADER_END_RE = /^#EHDR$/

      # Parse the header.
    def parse_header(rawtext)
      rawbuf = rawtext.split("\n")

      loop do
        break if rawbuf.nil? or rawbuf.empty?

        if rawbuf[0] =~ HEADER_END_RE
          rawbuf.shift
          break
        end

        match = HEADER_RE.match(rawbuf[0])

        if match
          case match[1].intern
          when :id
            @page_id = match[2].to_i
          when :topic
            @topic = match[2]
          when :version
            @version      = match[2].to_i
            @old_version  = @version - 1
          end
          rawbuf.shift
        end
      end

      rawbuf.join("\n")
    end

      # Parse the content.
    def parse_content(content, project)
      parsed = @ruwiki.markup.parse(content, project)

      parsed
    end
  end
end
