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
    # The list of known backends.
  KNOWN_BACKENDS  = [:flatfiles]

    # The Ruwiki backend delegator. Ruwiki will always instantiate a version
    # of this class which delegates the actual method execution to the Backend
    # class. Error handling is handled by capturing (and possibly forwarding)
    # exceptions raised by the delegate class.
  class BackendDelegator
    def initialize(ruwiki, backend)
      @message = ruwiki.config.message
      options = ruwiki.config.storage_options

      raise RuntimeError, @message[:backend_unknown] % [backend] unless Ruwiki::KNOWN_BACKENDS.include?(backend)
      beconst = (befile = backend.id2name).capitalize

      require "ruwiki/backend/#{befile}"

      @delegate = Ruwiki::Backend.const_get(beconst).new(options)
    rescue Ruwiki::Backend::BackendError => e
      if e.kind_of?(Array)
        raise Ruwiki::Backend::BackendError.new(nil), @message[e.reason[0]] % e.reason[1]
      else
        raise
      end
    end

      # Retrieve the specified topic and project page. Calls Backend#load
      # after verifying that the project exists.
    def retrieve(topic, project = 'Default')
      unless page_exists?(topic, project)
        if project_exists?(project)
          return { :content => "", :topic => topic, :project => project }
        else
          return { :content => @message[:project_does_not_exist] % [project],
                   :topic   => topic, :project => project }
        end
      end

      buffer = @delegate.load(topic, project)
      return { :rawtext => buffer.join(""), :project => project, :topic => topic }
    rescue Errno::EACCES => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:no_access_to_read_topic] % [project, topic]
    rescue Exception => e
      p = [project, topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_retrieve_topic] % p
    end

      # Stores the specified topic and project page.
    def store(page)
      @delegate.store(page)
    rescue Errno::EACCES => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:no_access_to_store_topic] % [page.project, page.topic]
    rescue Exception => e
      p = [page.project, page.topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_store_topic] % p
    end

      # Destroys the specified topic and project page.
    def destroy(page)
      @delegate.destroy(page)
    rescue Errno::EACCES => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:no_access_to_destroy_topic] % [page.project, page.topic]
    rescue Exception => e
      p = [project, topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_destroy_topic] % p
    end

      # Releases the lock on the page.
    def release_lock(page, address = 'UNKNOWN')
      @delegate.release_lock(page, address)
    rescue Ruwiki::Backend::BackendError
      raise Ruwiki::Backend::BackendError.new(nil), @message[:cannot_release_lock] % [page.project, page.topic]
    rescue Errno::EACCES, Exception => e
      p = [project, topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:error_releasing_lock] % p
    end

      # Attempts to obtain a lock on the page.
    def obtain_lock(page, address = 'UNKNOWN', timeout = 600)
      @delegate.obtain_lock(page, address, timeout)
    rescue Ruwiki::Backend::BackendError
      raise Ruwiki::Backend::BackendError.new(nil), @message[:cannot_obtain_lock] % [page.project, page.topic]
    rescue Errno::EACCES, Exception => e
      p = [project, topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:error_creating_lock] % p
    end

      # Checks to see if the project exists.
    def project_exists?(project)
      @delegate.project_exists?(project)
    end

      # Checks to see if the page exists.
    def page_exists?(topic, project = 'Default')
      @delegate.page_exists?(topic, project)
    end

      # Attempts to create the project.
    def create_project(project)
      @delegate.create_project(project)
    rescue Ruwiki::Backend::ProjectExists => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:project_already_exists] % [project]
    rescue Errno::EACCES => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:no_access_to_create_project] % [project]
    rescue Exception => e
      p = [project, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_create_project] % p
    end

      # Attempts to destroy the project.
    def destroy_project(project)
      @delegate.destroy_project(project)
    rescue Errno::EACCES => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:no_access_to_destroy_project] % [project]
    rescue Exception => e
      p = [project, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_destroy_project] % p
    end
  end

    # The Ruwiki backend abstract class and factory.
  class Backend
    class ProjectExists < StandardError #:nodoc:
    end
    class BackendError < StandardError #:nodoc:
      attr_reader :reason

      def initialize(reason, *args)
        @reason = reason
      end
    end
    def initialize(storage_options)
    end

  private
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
  end
end
