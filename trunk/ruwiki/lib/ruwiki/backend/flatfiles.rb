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
require 'ruwiki/backend/_corefiles'

  # Stores Ruwiki pages as flatfiles.
class Ruwiki::Backend::Flatfiles < Ruwiki::Backend
  include Ruwiki::Backend::CoreFiles

    # Initializes the Flatfiles backend. The known options are known for
    # Flatfiles:
    #
    # :data_path::    The directory in which the wiki files will be found. By
    #                 default, this is "./data/"
    # :extension::    The extension of the wiki files. By default, this is
    #                 +nil+ in the backend.
    # :default_page:: The default page for a project. By default, this is
    #                 ProjectIndex. This is provided only so that the backend
    #                 can make reasonable guesses.
  def initialize(options)
    super
  end

    # Provides a HEADER marker.
  HEADER_RE = /^(?:([a-z]+)!)?([a-z][-a-z]+):\t(.*)$/
  FIRST_TAB = /^\t/

    # Loads the topic page from disk.
  def load(topic, project)
    Ruwiki::Backend::Flatfiles.load(File.read(page_file(topic, project)))
  end

    # Saves the topic page -- and its difference with the previous version
    # -- to disk.
  def store(page)
    pagefile  = page_file(page.topic, page.project)
    newpage   = Ruwiki::Backend::Flatfiles.dump(page.export)
    make_rdiff(page, pagefile, newpage)

    File.open(pagefile, 'wb') { |f| f.puts newpage }
  end

    # Destroys the topic page.
  def destroy(page)
    super
  end

    # Checks to see if the project exists.
  def project_exists?(project)
    super
  end

    # Checks to see if the page exists.
  def page_exists?(topic, project = 'Default')
    super
  end

    # Tries to create the project.
  def create_project(project)
    super
  end

    # Tries to destroy the project.
  def destroy_project(project)
    super
  end

    # String search all topic names and content in a project and return a
    # has of topic hits
  def search_project(project, searchstr)
    super
  end

    # Attempts to obtain a lock on the topic page.
  def obtain_lock(page, address = 'UNKNOWN', timeout = 600)
    super
  end

    # Releases the lock on the topic page.
  def release_lock(page, address = 'UNKNOWN')
    super
  end

    # list projects found in data path
  def list_projects
    super
  end

    # list topics found in data path
  def list_topics(project)
    super
  end

  class << self
    NL_RE       = /\n/
    NL_END_RE   = /\n$/

    def dump(page_hash)
      dumpstr = ""

      page_hash.keys.sort.each do |sect|
        page_hash[sect].keys.sort.each do |item|
          val = page_hash[sect][item]

          case [sect, item]
          when ['properties', 'create-date'], ['properties', 'edit-date']
            val = val.to_i
          when ['properties', 'editable']
            val = (val ? 'true' : 'false')
          else # string values
            val = val.to_s
            vala = val.split(NL_RE)
            if vala.size == 1
              line = val
              line.gsub!(NL_END_RE) { "\\n" }
            else
              line = vala.shift
              vala.each { |vl| line << "\n\t#{vl}" }
            end
          end
          
          dumpstr << "#{sect}!#{item}:\t#{line}\n"
        end
      end

      dumpstr
    end

    def load(buffer)
      page = Ruwiki::Page::NULL_PAGE.dup
      return page if buffer.empty?

      buffer = buffer.split(NL_RE)

      if HEADER_RE.match(buffer[0]).nil?
        raise Ruwiki::Backend::InvalidFormatError
      end

      sect = item = nil
      
      buffer.each do |line|
        line.chomp!
        match = HEADER_RE.match(line)

          # If there is no match, add the current line to the previous match.
          # Remove the leading \t, though.
        if match.nil?
          page[sect][item] << "\n#{line.gsub(FIRST_TAB, '')}"
        else
          cap = match.captures
            # Set the section, if provided.
          sect = cap[0] unless cap[0].nil?
          item = cap[1]
          val  = cap[2]

          case [sect, item]
          when ['ruwiki', 'content-version'], ['properties', 'version']
            val = val.to_i
          when ['properties', 'entropy']
            val = val.to_f
          when ['properties', 'create-date'], ['properties', 'edit-date']
            val = Time.at(val.to_i)
          when ['properties', 'editable']
            val = (val == 'true')
          else # string values
            nil
          end

          page[sect][item] = val
        end
      end

      page
    end
  end
end
