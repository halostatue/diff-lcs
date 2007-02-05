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
require 'algorithm/diff'

class Ruwiki
    # The Ruwiki backend abstract class and factory.
  class Backend
    BACKENDS  = [:flatfiles] # :postgresql, :mysql, :odbc]

    STORE_ERROR = "No access to store topic.<br />\nThis is probably a RuWiki configuration error."

    class ProjectExists < StandardError #:nodoc:
    end
    class BackendError < StandardError #:nodoc:
    end

      # The default initializer for backend classes.
    def initialize(ruwiki)
      @ruwiki = ruwiki
    end

      # The Backend Factory. Requires and initializes the backend requested.
    def self.[](backend, ruwiki)
      raise RuntimeError, "Unknown Backend #{backend}" unless BACKENDS.include?(backend)
      befile = backend.to_s
      beconst = befile.capitalize

      require "ruwiki/backend/#{befile}"

      be = eval("Ruwiki::Backend::#{beconst}")
      be.new(ruwiki)
    end

      # Retrieve the specified topic and project page. Calls Backend#load
      # after verifying that the project exists.
    def retrieve(topic, project = 'Default')
      unless page_exists?(topic, project)
        if project_exists?(project)
          return Ruwiki::Page.new(@ruwiki,
                                  :content  => "",
                                  :topic    => topic,
                                  :project  => project)
        else
          return Ruwiki::Page.new(@ruwiki,
                                  :content  => "Project #{project} doesn't exist",
                                  :topic    => topic,
                                  :project  => project)
        end
      end

      buffer = load(topic, project)
      Ruwiki::Page.new(@ruwiki,
                       :rawtext => buffer.join(''),
                       :project => project,
                       :topic   => topic)
    end

        # Creates the current diff object.
      def make_diff(page, oldpage, newpage)
        {
          'old_version' => page.old_version,
          'new_version' => page.version,
          'change_date' => Time.now,
          'change_ip'   => page.change_ip,
          'change_id'   => page.change_id,
          'diff'        => Diff.diff(oldpage, newpage)
        }
      end

      # Stores the specified topic and project page. Calls Backend#save.
    def store(page)
      save(page)
    end

      # Destroies the specified topic and project page.
    def destroy(page)
      raise
    end

      # Releases the lock on the page.
    def release_lock(page)
      raise
    end

      # Attempts to obtain a lock on the page.
    def obtain_lock(page)
      raise
    end

      # Checks to see if the project exists.
    def project_exists?(project)
      raise
    end

      # Checks to see if the page exists.
    def page_exists?(topic, project = 'Default')
      raise
    end

      # Attempts to create the project.
    def create_project(project)
      raise
    end

      # Attempts to destroy the project.
    def destroy_project(project)
      raise
    end

    def load(topic, project) #:nodoc:
      raise
    end

    def save(page) #:nodoc
      raise
    end
  end
end
