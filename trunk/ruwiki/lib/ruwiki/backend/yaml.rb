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
require 'yaml'

  # Stores Ruwiki pages as flatfiles.
class Ruwiki::Backend::Yaml < Ruwiki::Backend
  include Ruwiki::Backend::CoreFiles

    # Initializes the Yaml backend. The known options are known for Yaml:
    #
    # :data_path::    The directory in which the wiki files will be found. By
    #                 default, this is "./data/"
    # :extension::    The extension of the wiki files. By default, this is
    #                 +nil+ in the backend.
    # :default_page:: The default page for a project. By default, this is
    #                 ProjectIndex. This is provided only so that the backend
    #                 can make reasonable guesses.
  def initialize(options)
    raise Ruwiki::Backend::BackendError.new(:yaml_requires_182_or_higher) unless RUBY_VERSION >= "1.8.2"
    super
  end

    # Loads the topic page from disk.
  def load(topic, project)
    Ruwiki::Backend::Yaml.load(File.read(page_file(topic, project)))
  end

    # Saves the topic page -- and its difference with the previous version
    # -- to disk.
  def store(page)
    pagefile  = page_file(page.topic, page.project)
    newpage   = Ruwiki::Backend::Yaml.dump(page.export)
    make_rdiff(page, pagefile, newpage)

    File.open(pagefile, 'wb') { |f| f.puts newpage }
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

    # String search all topic names and content in a project and return a
    # has of topic hits
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
      page = load(topic, project) rescue {}
      page['page'].each_value do |item|
        item = item.join("") if item.kind_of?(Array)
        item ||= ""
        hits[topic] += item.scan(re_search).size
      end
    end

    hits
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

  class << self
    def dump(page_hash)
      ::YAML.dump(page_hash)
    end

    def load(buffer)
      ::YAML.load(buffer)
    rescue ArgumentError
      raise Ruwiki::Backend::InvalidFormatError
    end
  end
end
