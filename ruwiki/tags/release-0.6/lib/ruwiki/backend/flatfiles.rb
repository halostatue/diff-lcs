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
  class Backend
      # Stores Ruwiki pages as flatfiles.
    class Flatfiles < Ruwiki::Backend
        # Initializes the flatfile backend.
      def initialize(ruwiki)
        ruwiki.config.data_path << "/" unless (ruwiki.config.data_path[-1] == ?/)
        raise Ruwiki::Backend::StandardError,
          "data directory #{ruwiki.config.data_path} does not exist." unless File.exists?(ruwiki.config.data_path)
        @data_path = ruwiki.config.data_path
        super ruwiki
      end

        # Loads the topic page from disk.
      def load(topic, project)
        pagefile = page_file(topic, project)
        buffer = File.readlines(pagefile)
      rescue Errno::EACCES
        raise Ruwiki::Backend::BackendError,
          "No access to retrieve the topic."
      rescue Exception => e
        raise Ruwiki::Backend::BackendError,
          "Cannot retrieve project [#{project}] topic [#{topic}] (file #{pf}): #{e}"
      end


        # Saves the topic page -- and its difference with the previous version
        # -- to disk.
      def save(page)
        pf = page_file(page.topic, page.project)
        cf = "#{pf}.rdiff"

        oldfile = File.readlines(pf) rescue []
        oldfile.collect! { |e| e.chomp }
        newfile = page.rawtext.split("\n")

        diff = make_diff(page, oldfile, newfile)
        diffs = []
        File.open(cf, 'rb') { |f| diffs = Marshal.load(f) } if File.exists?(cf)
        diffs << diff
        changes = Marshal.dump(diffs)

        File.open(cf, 'wb') { |cfh| cfh.print changes }
        File.open(pf, 'wb') { |pfh| pfh.puts page.rawtext }
      rescue Errno::EACCES
        raise BackendError, Ruwiki::Backend::STORE_ERROR
      rescue Exception => e
        raise BackendError, "Error storing page project [#{page.project}] topic [#{page.topic}]: #{e}<br />#{e.backtrace.join("<br />")}"
      end

        # Destroys the topic page.
      def destroy(page)
        pf = page_file(page.topic, page.project)
        File.unlink(pf) if File.exists?(pf)
      rescue Errno::EACCES
        raise BackendError, "No access to destroy topic."
      rescue Exception => e
        raise BackendError, "Unable to destroy project [#{project}] topic [#{topic}]: #{e}"
      end

        # Checks to see if the project exists.
      def project_exists?(project)
        pd = project_directory(project)
        File.exists?(pd) and File.directory?(pd)
      end

        # Checks to see if the page exists.
      def page_exists?(topic, project = 'Default')
        pf = page_file(topic, project)
        project_exists?(project) and File.exists?(pf)
      end

        # Tries to create the project.
      def create_project(project)
        pd = project_directory(project)
        raise ProjectExists, "Project #{project} already exists." if File.exists?(pd)
        Dir.mkdir(pd)
      rescue Errno::EACCES
        raise BackendError, "No access to create project."
      rescue Exception => e
        raise BackendError, "Unable to create project [#{project}]: #{e}"
      end

        # Tries to destroy the project.
      def destroy_project(project)
        pd = project_directory(project)
        Dir.rmdir(pd) if File.exists?(pd) and File.directory?(pd)
      rescue Errno::EACCES
        raise BackendError, "No access to destroy project."
      rescue Exception => e
        raise BackendError, "Unable to destroy project [#{project}]: #{e}"
      end

        # Attempts to obtain a lock on the topic page.
      def obtain_lock(page)
        lf = "#{page_file(page.topic, page.project)}.lock"

        lock_okay = false
          # See if we have the lock already.
        if File.exists?(lf)
          data = File.readlines(lf)
            # If the lock belongs to this address, we don't care how old it
            # is. Thus, release it.
          lock_okay ||= (data[0].chomp == @ruwiki.request.environment['REMOTE_ADDR'])
            # If the lock is older than 10 minutes, release it.
          lock_okay ||= ((data[1].to_i + 600) < Time.now.to_i)
        else
          lock_okay = true
        end

        if lock_okay
          open(lf, 'w') { |lfh| lfh.puts "#{@ruwiki.request.environment['REMOTE_ADDR']}\n#{Time.now.to_i + 600}" }
        else
          raise BackendError, "Unable to obtain a lock on page project [#{page.project}] topic [#{page.topic}]. Try again in ten minutes."
        end
      rescue Errno::EACCES
        raise BackendError, "unable to create lock on page project [#{page.project}] topic [#{page.topic}]."
      rescue BackendError
        raise
      rescue Exception => e
        raise BackendError, "Error storing page project [#{page.project}] topic [#{page.topic}]: #{e}"
      end

        # Releases the lock on the topic page.
      def release_lock(page)
        lf = "#{page_file(page.topic, page.project)}.lock"

        lock_okay = false
        if File.exists?(lf)
          data = File.readlines(lf)
            # If the lock belongs to this address, then we can safely remove
            # it.
          lock_okay ||= (data[0].chomp == @ruwiki.request.environment['REMOTE_ADDR'])
            # If the lock is older than 10 minutes, release it.
          lock_okay ||= (data[1].to_i < Time.now.to_i)
        else
          lock_okay = true
        end

        if lock_okay
          File.unlink(lf) if File.exists?(lf)
        else
          raise BackendError, "Unable to release the lock on page project [#{page.project}] topic [#{page.topic}]. Try again in ten minutes."
        end
      rescue Errno::EACCES
        raise BackendError, "unable to create lock on page [#{page.project}] topic [#{page.topic}]."
      rescue BackendError
        raise
      rescue Exception => e
        raise BackendError, "Error storing page project [#{page.project}] topic [#{page.topic}]: #{e}"
      end

    private
      def project_directory(project)
        "#{@data_path}#{project}"
      end

      def page_file(topic, project = 'Default')
        "#{project_directory(project)}/#{topic}"
      end
    end
  end
end
