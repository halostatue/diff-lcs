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
require 'diff/lcs'

class Ruwiki
    # The list of known backends.
  KNOWN_BACKENDS  = %w(flatfiles)

    # The Ruwiki backend delegator. Ruwiki will always instantiate a version
    # of this class which delegates the actual method execution to the Backend
    # class. Error handling is handled by capturing (and possibly forwarding)
    # exceptions raised by the delegate class.
  class BackendDelegator
    def initialize(ruwiki, backend)
      @message = ruwiki.config.message
      @time_format = ruwiki.config.time_format || "%H:%M:%S"
      @date_format = ruwiki.config.date_format || "%Y.%m.%d"
      @datetime_format = ruwiki.config.datetime_format || "#{@date_format} #{@time_format}"
      options = ruwiki.config.storage_options
      options['default-page'] = ruwiki.config.default_page

      unless Ruwiki::KNOWN_BACKENDS.include?(backend)
        raise RuntimeError, @message[:backend_unknown] % [backend] 
      end

      beconst = backend.capitalize

      require "ruwiki/backend/#{backend}"

      beoptions = options[backend]
      @delegate = Ruwiki::Backend.const_get(beconst).new(beoptions)
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
        exported = Ruwiki::Page::NULL_PAGE.dup
        exported['properties'] = {
          'title'         => topic,
          'topic'         => topic,
          'project'       => project,
          'create-date'   => Time.now,
          'edit-date'     => Time.now,
          'editable'      => true,
          'indexable'     => true,
          'entropy'       => 0.0,
          'html-headers'  => [],
          'version'       => 0
        }
        exported['page'] = {
          'header'  => nil,
          'footer'  => nil
        }

        if project_exists?(project)
          exported['page']['content'] = ""
        else
          exported['page']['content'] = @message[:project_does_not_exist] % [project]
        end
        return exported
      end

      return @delegate.load(topic, project)
    rescue Ruwiki::Backend::InvalidFormatError => e
      raise Ruwiki::Backend::BackendError.new(nil), @message[:page_not_in_backend_format] % [project, topic, @delegate.class]
    rescue Errno::EACCES => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:no_access_to_read_topic] % [project, topic]
    rescue Exception => e
      p = [project, topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_retrieve_topic] % p
    end

      # Stores the specified topic and project page.
    def store(page)
      @delegate.store(page)

      # update change page
      begin
        recent_changes = nil
        if (page.topic == 'RecentChanges')
          recent_changes = page.dup
        else
          recent_changes = Page.new(retrieve('RecentChanges', page.project))
        end

        changeline = "\n; #{Time.now.strftime(@datetime_format)}, #{page.topic} : #{page.edit_comment}"

        # add changeline to top of page
        recent_changes.content = changeline + (recent_changes.content || "")
        @delegate.store(recent_changes)
      rescue Exception => e
        raise "Couldn't save RecentChanges\n#{e.backtrace}"
      end
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
      p = [page.project, page.topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_destroy_topic] % p
    end

      # Releases the lock on the page.
    def release_lock(page, address = 'UNKNOWN')
      time    = Time.now.to_i
      @delegate.release_lock(page, time, address)
    rescue Ruwiki::Backend::BackendError
      raise Ruwiki::Backend::BackendError.new(nil), @message[:cannot_release_lock] % [page.project, page.topic]
    rescue Errno::EACCES, Exception => e
      p = [page.project, page.topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:error_releasing_lock] % p
    end

      # Attempts to obtain a lock on the page. The lock 
    def obtain_lock(page, address = 'UNKNOWN', timeout = 600)
      time    = Time.now.to_i
      expire  = time + timeout
      @delegate.obtain_lock(page, time, expire, address)
    rescue Ruwiki::Backend::BackendError
      raise Ruwiki::Backend::BackendError.new(nil), @message[:cannot_obtain_lock] % [page.project, page.topic]
    rescue Errno::EACCES, Exception => e
      p = [page.project, page.topic, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
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

    def search_all_projects(searchstr)
      if @delegate.respond_to?(:search_all_projects)
        @delegate.search_all_projects(searchstr) 
      else
        search_all_projects_default(searchstr)
      end
    end

      # Attempts to search all projects. This is the default
      # search_all_projects used unless the delegate implements
      # a specialized search_all_projects.
    def search_all_projects_default(searchstr)
      hits = {}
      list_projects.each do |project|
        lhits = search_project(project, searchstr)
          # Transform the keys from project local to global links.
        lhits.each { |key, val| hits["#{project}::#{key}"] = val }
      end
      hits
    end

      # Attempts to search a project
    def search_project(project, searchstr)
        #TODO: Validate searchstr is a safe regexp?
      @delegate.search_project(project, searchstr)
    rescue Exception => e
      p = [project, searchstr, e.class, %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:search_project_fail] % p
    end

      # Return an array of projects
    def list_projects
      @delegate.list_projects
    rescue Errno::EACCES => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:no_access_list_projects]
    rescue Exception => e
      p = ['', %Q~#{e}<br />\n#{e.backtrace.join('<br />\n')}~]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_list_projects] % p
    end

      # Return an array of projects
    def list_topics(projname)
      @delegate.list_topics(projname)
    rescue Errno::EACCES => e
      raise Ruwiki::Backend::BackendError.new(e), @message[:no_access_list_topics] % [projname]
    rescue Exception => e
      p = [projname, e.message]
      raise Ruwiki::Backend::BackendError.new(e), @message[:cannot_list_topics] % p
    end
  end

    # The Ruwiki backend abstract class and factory.
  class Backend
    class ProjectExists < RuntimeError #:nodoc:
    end
    class InvalidFormatError < RuntimeError #:nodoc:
    end
    class BackendError < RuntimeError #:nodoc:
      attr_reader :reason

      def initialize(reason, *args)
        if @reason.respond_to?(:message)
          @reason = reason.message
        else
          @reason = reason
        end
      end
    end
    def initialize(storage_options)
    end

  private
    NL_RE = %r{\n} #:nodoc:

    def map_diffset(diffset)
      diffset.map do |hunk|
        if hunk.kind_of?(Array)
          hunk.map { |change| change.to_a }
        else
          hunk.to_a
        end
      end
    end

      # Creates the current diff object. This is made from two
      # Ruwiki::Page#export hashes.
    def make_diff(oldpage, newpage)
      oldpage = oldpage.export if oldpage.kind_of?(Ruwiki::Page)
      newpage = newpage.export if newpage.kind_of?(Ruwiki::Page)

      diff = Hash.new

      newpage.keys.sort.each do |sect|
        newpage[sect].keys.sort.each do |item|
          oldval = oldpage[sect][item]
          newval = newpage[sect][item]

          case [sect, item]
          when ['properties', 'html-headers']
              # Protect against NoMethodError.
            oldval ||= []
            newval ||= []
            val = Diff::LCS.sdiff(oldval, newval, Diff::LCS::ContextDiffCallbacks)
          when ['ruwiki', 'content-version'], ['properties', 'version'],
               ['properties', 'entropy']
            val = Diff::LCS.sdiff([oldval], [newval], Diff::LCS::ContextDiffCallbacks)
          when ['properties', 'create-date'], ['properties', 'edit-date']
            val = Diff::LCS.sdiff([oldval.to_i], [newval.to_i], Diff::LCS::ContextDiffCallbacks)
          else
              # Protect against NoMethodError.
            val = Diff::LCS.sdiff(oldval.to_s.split(NL_RE), newval.to_s.split(NL_RE), Diff::LCS::ContextDiffCallbacks)
          end

          (diff[sect] ||= {})[item] = map_diffset(val) unless val.nil? or val.empty?
        end
      end

      diff_hash = {
        'old_version' => oldpage['properties']['version'],
        'new_version' => newpage['properties']['version'],
        'edit-date'   => newpage['properties']['edit-date'].to_i,
        'editor-ip'   => newpage['properties']['editor-ip'],
        'editor'      => newpage['properties']['editor'],
        'diff'        => diff
      }
    end
  end
end
