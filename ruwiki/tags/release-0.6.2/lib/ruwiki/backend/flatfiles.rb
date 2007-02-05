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
  class Backend
      # Stores Ruwiki pages as flatfiles.
    class Flatfiles < Ruwiki::Backend
        # Initializes the flatfile backend. This will read
        # storage_options[:flatfiles] to determine the options set by the
        # user. The following options are known for <tt>:flatfiles</tt>:
        #
        # :data_path::  The directory in which the wiki files will be found.
        #               By default, this is "./data/"
        # :extension::  The extension of the wiki files. By default, this is
        #               +nil+.
      def initialize(storage_options)
        options = storage_options[:flatfiles]
        options[:data_path] ||= "./data/"
        @data_path  = options[:data_path]
        @extension  = options[:extension]
        if not (File.exists?(@data_path) and File.directory?(@data_path))
          raise Ruwiki::Backend::BackendError.new([:flatfiles_no_data_directory, [@data_path]])
        end
        super options
      end

        # Loads the topic page from disk.
      def load(topic, project)
        pagefile = page_file(topic, project)
        buffer = File.readlines(pagefile)
      end

        # Saves the topic page -- and its difference with the previous version
        # -- to disk.
      def store(page)
        pf = page_file(page.topic, page.project)
        cf = "#{pf}.rdiff"

        oldfile = File.readlines(pf) rescue []
        oldfile.collect! { |e| e.chomp }
        newfile = page.rawtext.split(/\n/)

        diff = make_diff(page, oldfile, newfile)
        diffs = []
        File.open(cf, 'rb') { |f| diffs = Marshal.load(f) } if File.exists?(cf)
        diffs << diff
        changes = Marshal.dump(diffs)

        File.open(cf, 'wb') { |cfh| cfh.print changes }
        File.open(pf, 'wb') { |pfh| pfh.puts page.rawtext }
      end

        # Destroys the topic page.
      def destroy(page)
        pf = page_file(page.topic, page.project)
        File.unlink(pf) if File.exists?(pf)
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
        raise Ruwiki::Backend::ProjectExists if File.exists?(pd)
        Dir.mkdir(pd)
      end

        # Tries to destroy the project.
      def destroy_project(project)
        pd = project_directory(project)
        Dir.rmdir(pd) if File.exists?(pd) and File.directory?(pd)
      end

        # Attempts to obtain a lock on the topic page.
      def obtain_lock(page, address = 'UNKNOWN', timeout = 600)
        pf = page_file(page.topic, page.project)
        lf = "#{pf}.lock"
        time = Time.now.to_i

        lock_okay = false
          # See if we have the lock already.
        if File.exists?(lf)
          data = File.readlines(lf)
            # If the lock belongs to this address, we don't care how old it
            # is. Thus, release it.
          lock_okay ||= (data[0].chomp == address)
            # If the lock is older than 10 minutes, release it.
          lock_okay ||= (data[1].to_i < time)
        else
          lock_okay = true
        end

        if lock_okay
          open(lf, 'w') { |lfh| lfh.puts "#{address}\n#{time + timeout}" }
        else
          raise Ruwiki::Backend::BackendError(nil)
        end
      end

        # Releases the lock on the topic page.
      def release_lock(page, address = 'UNKNOWN')
        pf = page_file(page.topic, page.project)
        lf = "#{pf}.lock"
        time = Time.now.to_i

        lock_okay = false
        if File.exists?(lf)
          data = File.readlines(lf)
            # If the lock belongs to this address, then we can safely remove
            # it.
          lock_okay ||= (data[0].chomp == address)
            # If the lock is older than 10 minutes, release it.
          lock_okay ||= (data[1].to_i < time)
        else
          lock_okay = true
        end

        if lock_okay
          File.unlink(lf) if File.exists?(lf)
        else
          raise Ruwiki::Backend::BackendError.new(nil)
        end
      end

    private
      def project_directory(project)
        File.join(@data_path, project)
      end

      def page_file(topic, project = 'Default')
        if @extension.nil?
          File.join(project_directory(project), topic)
        else
          File.join(project_directory(project), "#{topic}.#{@extension}")
        end
      end
    end
  end
end
