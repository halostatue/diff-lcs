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

  # Ruwiki configuration.
class Ruwiki::Config
  include Ruwiki::Exportable

  CONFIG_NAME = 'ruwiki.conf'

  exportable_group 'ruwiki-config'
    # Sets or returns the logger. The logger, if set, must respond to the same
    # methods as WEBrick::Logger.
  attr_accessor :logger
    # Sets or returns the time format whenever time is outputted in Ruwiki.
    # Default is <tt>%H:%M:%S</tt> (23:59:59).
  attr_accessor :time_format
  exportable :time_format
    # Sets or returns the date format whenever time is outputted in Ruwiki.
    # Default is <tt>%Y.%m.%d</tt> (2004.08.04).
  attr_accessor :date_format
  exportable :date_format
    # Sets or returns the date-time format whenever time is outputted in
    # Ruwiki. Default is <tt>%Y.%m.%d %H:%M:%S</tt> (2004.08.04 23:59:59).
  attr_accessor :datetime_format
  exportable :datetime_format
    # Adds additional information to the (rare) error reports. Defaults to
    # +false+.
  attr_accessor :debug
  exportable :debug
    # The default page for display when Ruwiki is called without any arguments.
    # Defaults to +ProjectIndex+
  attr_accessor :default_page
  exportable :default_page
    # The default project for display when Ruwiki is called without any
    # arguments or a project specification. Defaults to +Default+
  attr_accessor :default_project
  exportable :default_project
    # The authentication mechanism as a String. Corresponds to a filename that
    # will be found in ruwiki/auth. In this version of Ruwiki, only one
    # authentication mechanism will be found -- for dealing with authenticating
    # users already logged into RubyForge.
  attr_accessor :auth_mechanism
  exportable :auth_mechanism
    # Options for the authentication mechanism as a Hash. This will be
    # passed to the authenticator defined in :auth_mechanism. 
  attr_accessor :auth_options
  exportable :auth_options
    # The storage type as a String. Corresponds to a filename that will be
    # found in ruwiki/backend. NOTE: The yaml and marshal storage types have
    # been removed from Ruwiki 0.9.0, to be replaced with a single storage
    # type of Flatfiles. Now, the YAML and Marshal formats can be enabled by
    # setting options in the @storage_options field.
  attr_accessor :storage_type
  exportable :storage_type
    # The options for the specified storage type. This is a hash of hashes with
    # auto-vifification. See the storage type for available options.
  attr_reader   :storage_options
  exportable   :storage_options
    # The path for templates. Defaults to <tt>./templates/</tt>.
  attr_accessor :template_path
  exportable :template_path
    # The name of the Wiki. Defaults to <tt>ruwiki</tt>
  attr_accessor :title
  exportable :title
    # The email address of the webmaster for the Wiki. Defaults to +nil+.
  attr_accessor :webmaster
  exportable :webmaster
    # The name of the Ruwiki CSS file. Defaults to <tt>ruwiki.css</tt>.
  attr_accessor :css
  exportable :css
    # The template set. Templates are always named as
    # <template_path>/<template_set>/<template_name>. Template filename. Must
    # be reachable by File#read.
  attr_accessor :template_set
  exportable :template_set
    # Ruwiki is internationalized. This method sets the Ruwiki error messages
    # (and a few other messages) )to the specified language Module. The
    # language Module must have a constant Hash called +Message+ containing a
    # set of symbols and localized versions of the messages associated with
    # them.
    #
    # If the file 'ruwiki/lang/es.rb' contains the module
    # <tt>Ruwiki::Lang::ES</tt>, the error messages for RSS could be localized
    # to Español thus:
    #
    #   require 'ruwiki/lang/es'
    #   ...
    #   wiki.config.language = Ruwiki::Lang::ES
    #
    # Localization is per wiki instance. In a servlet environment, this may
    # mean that only a single language is recognised.
    #
    # See Ruwiki::Lang::EN for more information.
  attr_accessor :language
  exportable :language
    # The message hash.
  attr_reader   :message

  def language=(l) #:nodoc:
    @language = l
    @message = l::Message
  end

  # Returns the specified template as a string.
  def template(name)
    File.read(File.join(@template_path, @template_set, "#{name.to_s}.tmpl"))
  rescue Errno::ENOENT
    raise ConfigError, message[:no_template_found] % [name.inspect, @template_set]
  end

  # Returns the CSS stylesheet content for the Wiki. This previously
  # returned the <link> to the stylesheet, but instead returns a <style>
  # block in the head so that the CSS is kept with the template set, which
  # may be kept outside of the HTML area.
  def css_link
    %Q[<style type="text/css" media="screen,print">#{File.read(File.join(@template_path, @template_set, @css))}</style>]
  end

  # Creates a new configuration object.
  def initialize(exportable = {})
    rc = exportable['ruwiki-config'] || {}
    @debug            = (rc['debug'] == "false") ? false : true
    @default_project  = rc['default-project'] || "Default"
    @default_page     = rc['default-page']    || "ProjectIndex"
    @auth_mechanism   = rc['auth-mechanism']  || nil

    case rc['auth-options']
    when nil, ""
      @auth_options   = {}
    else
      @auth_options   = Ruwiki::Exportable.load(rc['auth-options'])['default']
    end

    case rc['storage-type']
    when nil, ""
      @storage_type   = 'flatfiles'
    else
      @storage_type   = rc['storage-type']
    end

      # in 'type!name:<Tab>value\n' format.
    if rc['storage-options'].nil? or rc['storage-options'].empty?
      @storage_options = Hash.new { |hh, kk| hh[kk] = {} }
    else
      @storage_options = Ruwiki::Exportable.load(rc['storage-options'])
      @storage_options.keys.each do |key|
        @storage_options[key] = @storage_options.delete(key)
      end
    end
    if @storage_options.empty?
      @storage_options[@storage_type]['extension'] = "ruwiki"
      @storage_options[@storage_type]['data-path'] = "./data"
      @storage_options[@storage_type]['format']    = "exportable"
    end

    @storage_options.each_value do |vv|
      if vv['extension'].nil? or vv['extension'].empty?
        vv['extension'] = "ruwiki"
      end
      if vv['data-path'].nil? or vv['data-path'].empty?
        vv['data-path'] = "./data"
      end
    end

    @template_path    = rc['template-path']   || "./templates/"
    @template_set     = rc['template-set']    || "default"
    @css              = rc['css']             || "ruwiki.css"
    @webmaster        = rc['webmaster']
    @title            = rc['title']           || "Ruwiki"
    @time_format      = rc['time-format']     || "%H:%M:%S"
    @date_format      = rc['date-format']     || "%Y.%m.%d"
    @datetime_format  = rc['datetime-format'] || "#{@date_format} #{@time_format}"
    case rc['language']
    when nil, ""
      self.language   = Ruwiki::Lang::EN
    else
      self.language   = Ruwiki::Lang::const_get(rc['language'].upcase)
    end
  end

  # Verifies that required configuration options are actually set. Right
  # now, it only checks the values that are defaulted to +nil+.
  def verify
    raise ConfigError, message[:no_webmaster_defined] if @webmaster.nil? or @webmaster.empty?
    raise ConfigError, message[:invalid_template_dir] % [@template_path] unless File.exists?(@template_path) and File.directory?(@template_path)
    t = File.join(@template_path, @template_set)
    raise ConfigError, message[:no_template_set] % [@template_set] unless File.exists?(t) and File.directory?(t)
  end

  # Provides the canonical export hash.
  def export
    exportable = super

    rc = exportable['ruwiki-config']

    rc['auth-options'] = Ruwiki::Exportable.dump({ 'default' => rc['auth-options']})

    rc['storage-options'] = Ruwiki::Exportable.dump(rc['storage-options'])
    rc['storage-type'] = rc['storage-type'].to_s
    rc['language']  = "#{rc['language']}".sub(/^.*?::([A-Z]+)$/, '\1').downcase
    exportable
  end

  class << self
    def write(file, config)
      if file.respond_to?(:write)
        file.puts(config.dump)
      else
        File.open(file, 'wb') { |ff| ff.puts(config.dump) }
      end
    end

    def read(file)
      data = nil
      if file.respond_to?(:read)
        data = file.read
      else
        File.open(file, 'rb') { |ff| ff.read }
      end
      hash = Ruwiki::Exportable.load(data)

      Ruwiki::Config.new(hash)
    end
  end

  class ConfigError < StandardError; end
end
