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
    # data_path::     The directory in which the wiki files will be found. By
    #                 default, this is "./data/"
    # extension::     The extension of the wiki files. By default, this is
    #                 +nil+ in the backend.
    # default_page::  The default page for a project. By default, this is
    #                 ProjectIndex. This is provided only so that the backend
    #                 can make reasonable guesses.
  def initialize(options)
    super
  end

    # Provides a HEADER marker.
    # Loads the topic page from disk.
  def load(topic, project)
    Ruwiki::Backend::Flatfiles.load(File.read(page_file(topic, project)))
  rescue Ruwiki::Exportable::InvalidFormatError
    raise Ruwiki::Backend::InvalidFormatError
  end

    # Saves the topic page -- and its difference with the previous version
    # -- to disk.
  def store(page)
    pagefile  = page_file(page.topic, page.project)
    export    = page.export
    newpage   = Ruwiki::Backend::Flatfiles.dump(export)
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

  class << self
    def dump(page_hash)
      Ruwiki::Exportable.dump(page_hash)
    end

    def load(buffer)
      page = Ruwiki::Page::NULL_PAGE.dup
      page.merge!(Ruwiki::Exportable.load(buffer))
      page
    end
  end
end
