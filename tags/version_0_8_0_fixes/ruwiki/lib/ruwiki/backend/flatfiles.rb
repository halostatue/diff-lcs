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
require 'ruwiki/exportable'
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
    # Loads the topic page from disk.
  def load(topic, project)
    page = Ruwiki::Page::NULL_PAGE.dup
    hash = Ruwiki::Exportable.load(File.read(page_file(topic, project)))
    hash.each_key { |ss| hash[ss].each { |ii, vv| page[ss][ii] = vv } }
    page
  rescue Ruwiki::Exportable::InvalidFormatError
    raise Ruwiki::Backend::InvalidFormatError
  end

    # Saves the topic page -- and its difference with the previous version
    # -- to disk.
  def store(page)
    pagefile  = page_file(page.topic, page.project)
    export    = page.export
    newpage   = Ruwiki::Exportable.dump(export)
    make_rdiff(pagefile, export)

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

    # String search all topic names and content in a project and
    # return a has of topic hits
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

# class << self
#   NL_RE       = /\n/

#   def dump(page_hash)
#     dumpstr = ""

#     page_hash.keys.sort.each do |sect|
#       page_hash[sect].keys.sort.each do |item|
#         val = page_hash[sect][item].to_s.split(NL_RE).join("\n\t")
#         dumpstr << "#{sect}!#{item}:\t#{val}\n"
#       end
#     end

#     dumpstr
#   end

#   def load(buffer)
#     page = Ruwiki::Page::NULL_PAGE.dup
#     return page if buffer.empty?

#     buffer = buffer.split(NL_RE)

#     if HEADER_RE.match(buffer[0]).nil?
#       raise Ruwiki::Backend::InvalidFormatError
#     end

#     sect = item = nil
#     
#     buffer.each do |line|
#       line.chomp!
#       match = HEADER_RE.match(line)

#         # If there is no match, add the current line to the previous match.
#         # Remove the leading \t, though.
#       if match.nil?
#         raise Ruwiki::Backend::InvalidFormatError if FIRST_TAB.match(line).nil?
#         page[sect][item] << "\n#{line.gsub(FIRST_TAB, '')}"
#       else
#         sect              = match.captures[0]
#         item              = match.captures[1]
#         page[sect][item]  = match.captures[2]
#       end
#     end

#     page
#   end
# end
end
