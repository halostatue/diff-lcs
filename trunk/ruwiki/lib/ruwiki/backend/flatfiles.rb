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

  # Stores Ruwiki pages as flatfiles.
class Ruwiki::Backend::Flatfiles < Ruwiki::Backend
    # Initializes the Flatfiles backend. The known options for the Flatfiles
    # backend are documented below.
    #
    # data-path::     The directory in which the wiki files will be found. By
    #                 default, this is "./data/"
    # extension::     The extension of the wiki files. By default, this is
    #                 +nil+ in the backend.
    # format::        The format of the files in the backend. By default,
    #                 this is 'exportable', a tagged data format produced by
    #                 Ruwiki::Exportable; alternative formats are 'yaml'
    #                 (::YAML.dump) and 'marshal' (::Marshal.dump).
    # default-page::  The default page for a project. By default, this is
    #                 ProjectIndex. This is provided only so that the backend
    #                 can make reasonable guesses.
  def initialize(options)
    @data_path = options['data-path'] || File.join(".", "data")
    @extension = options['extension']
    @format = case options['format']
              when 'exportable', nil
                Ruwiki::Exportable
              when 'yaml'
                ::YAML
              when 'marshal'
                ::Marshal
              end

    if @extension.nil?
      @extension_re = /$/
    else
      @extension_re = /\.#{@extension}$/
    end

    @default_page   = options['default-page'] || "ProjectIndex"
    if not (File.exists?(@data_path) and File.directory?(@data_path))
      raise Ruwiki::Backend::BackendError.new([:flatfiles_no_data_directory, [@data_path]])
    end

    super
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

    # String search all topic names and content in a project and
    # return a hash of topic hits.
  def search_project(project, searchstr)
    re_search = Regexp.new(searchstr, Regexp::IGNORECASE)

    hits = Hash.new { |h, k| h[k] = 0 }
    topic_list = list_topics(project)

    return hits if topic_list.empty?

      # search topic content
    topic_list.each do |topic|
        # search name
      hits[topic] += topic.scan(re_search).size

        # check content
      page = load(topic, project) rescue Ruwiki::Page::NULL_PAGE
      page['page'].each_value do |item|
        item = item.join("") if item.kind_of?(Array)
        item ||= ""
        hits[topic] += item.scan(re_search).size
      end
    end

    hits
  end

  def lock_okay?(page, time, address = 'UNKNOWN')
    lockokay  = false
    lockfile  = "#{page_file(page.topic, page.project)}.lock"

    if File.exists?(lockfile)
      data = File.read(lockfile).split(%r{!})
        # If the lock belongs to this address, we don't care how old it is.
        # Thus, release it.
      lock_okay ||= (data[0].chomp == address)
        # If the lock is older than 10 minutes, release it.
      lock_okay ||= (data[1].to_i < time)
    else
      lockokay = true
    end
  end

    # Attempts to obtain a lock on the topic page. This must return the lock
  def obtain_lock(page, time, expire, address = 'UNKNOWN')
    lock = "#{address}!#{expire}"

    if lock_okay?(page, time, address)
      File.open("#{page_file(page.topic, page.project)}.lock", 'wb') { |lfh| lfh.puts lock }
    else
      raise Ruwiki::Backend::BackendError.new(nil)
    end
    lock
  end

    # Releases the lock on the topic page.
  def release_lock(page, time, address = 'UNKNOWN')
    time = Time.now.to_i
    lockfile = "#{page_file(page.topic, page.project)}.lock"

    if lock_okay?(page, time, address)
      File.unlink(lockfile) if File.exists?(lockfile)
    else
      raise Ruwiki::Backend::BackendError.new(nil)
    end
    true
  end

    # list projects found in data path
  def list_projects
    Dir[File.join(@data_path, "*")].select do |d|
      File.directory?(d) and File.exist?(page_file(@default_page, File.basename(d)))
    end.map { |d| File.basename(d) }
  end

    # list topics found in data path
  def list_topics(project)
    pd = project_directory(project)
    raise Ruwiki::Backend::BackendError.new(:no_project) unless File.exist?(pd)

    Dir[File.join(pd, "*")].select do |f|
      f !~ /\.rdiff$/ and f !~ /\.lock$/ and File.file?(f) and f =~ @extension_re
    end.map { |f| File.basename(f).sub(@extension_re, "") }
  end

  def project_directory(project) # :nodoc:
    File.join(@data_path, project)
  end

  def page_file(topic, project = 'Default') # :nodoc:
    if @extension.nil?
      File.join(project_directory(project), topic)
    else
      File.join(project_directory(project), "#{topic}.#{@extension}")
    end
  end

  def make_rdiff(page_file, new_page)
    diff_file = "#{page_file}.rdiff"

    old_page = self.class.load(pf) rescue Ruwiki::Page::NULL_PAGE

    diffs = []
    File.open(diff_file, 'rb') { |f| diffs = Marshal.load(f) } if File.exists?(diff_file)
    diffs << make_diff(old_page, new_page)
    changes = Marshal.dump(diffs)

    File.open(diff_file, 'wb') { |f| f << changes }
  end

    # Provides a HEADER marker.
    # Loads the topic page from disk.
  def load(topic, project)
    data = nil
    File.open(page_file(topic, project), 'rb') { |f| data = f.read }

    Ruwiki::Page::NULL_PAGE.merge(@format.load(data))
  rescue Ruwiki::Exportable::InvalidFormatError, TypeError, ArgumentError
    raise Ruwiki::Backend::InvalidFormatError
  end

    # Saves the topic page -- and its difference with the previous version
    # -- to disk.
  def store(page)
    pagefile  = page_file(page.topic, page.project)
    export    = page.export
    newpage   = @format.dump(export)
    make_rdiff(pagefile, export)

    File.open(pagefile, 'wb') { |f| f.puts newpage }
  end
end
